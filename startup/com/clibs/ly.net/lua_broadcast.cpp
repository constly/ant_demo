//-------------------------------------------------------------
// Local area network (LAN) broadcasting
// for LAN room discovery functionality.
//-------------------------------------------------------------
#include <lua.hpp>
#include <bee/lua/binding.h>
#include <bee/lua/udata.h>

#if defined(_WIN32)
#   include <Ws2tcpip.h>
#	include <windows.h>
#	include <tlhelp32.h>
#else
#    include <arpa/inet.h>
#    include <netdb.h>
#    include <sys/un.h>
#    if defined(__FreeBSD__) || defined(__OpenBSD__)
#        include <netinet/in.h>
#        include <sys/socket.h>
#    endif
#endif

namespace luabind {

#if defined _WIN32
	using fd_t = uintptr_t;
#else
	using fd_t = int;
#endif
	#define net_success(x) ((x) == 0)
	
	static fd_t retired_fd = (fd_t)-1;

#if defined(_WIN32)
	static bool set_nonblock(fd_t s, bool set) noexcept {
		unsigned long nonblock = set ? 1 : 0;
		const int ok = ::ioctlsocket(s, FIONBIO, &nonblock);
		return net_success(ok);
	}
#elif defined(__APPLE__)
	static bool set_nonblock(int fd, bool set) noexcept {
		int r;
		do
			r = ::fcntl(fd, F_GETFL);
		while (r == -1 && errno == EINTR);
		if (r == -1)
			return false;
		if (!!(r & O_NONBLOCK) == set)
			return true;
		int flags = set ? (r | O_NONBLOCK) : (r & ~O_NONBLOCK);
		do
			r = ::fcntl(fd, F_SETFL, flags);
		while (!net_success(r) && errno == EINTR);
		return net_success(r);
	}
#endif

    static int get_error() noexcept {
	#if defined(_WIN32)
		return ::WSAGetLastError();
	#else
		return errno;
	#endif
    }

	struct BroadCast {
	public:
		sockaddr_in addr;
		fd_t sock = 0;
		char buffer[1024];
		sockaddr_in fromAddr;

	public:
		~BroadCast() { Close();} 

		void Close() {
			if (sock != retired_fd) {
	#if defined _WIN32
				::closesocket(sock);
	#else
				::close(sock);
	#endif
				sock = retired_fd;
			}
		}
	}; 

	static int bInitServer(lua_State* L) {
		luabind::BroadCast& Ins = bee::lua::checkudata<luabind::BroadCast>(L, 1);
		const char* ip = luaL_checkstring(L, 2);	
		int port = (int)luaL_checkinteger(L, 3);  	
		Ins.Close();
		Ins.sock = socket(AF_INET, SOCK_DGRAM, 0);
		if (Ins.sock < 0) return 0;
		
		int optval = 1;
		if (setsockopt(Ins.sock, SOL_SOCKET, SO_BROADCAST, (char*)&optval, sizeof(optval)) < 0) return 0;

		memset(&Ins.addr, 0, sizeof(Ins.addr));
		if (1 == inet_pton(AF_INET, ip, &Ins.addr.sin_addr)) {
			Ins.addr.sin_family = AF_INET;
			Ins.addr.sin_port   = htons(port);
		}

		lua_pushboolean(L, true);
		return 1;
	}

	static int bInitClient(lua_State* L) {
		luabind::BroadCast& Ins = bee::lua::checkudata<luabind::BroadCast>(L, 1);
		int port = (int)luaL_checkinteger(L, 2);  	
		Ins.Close();

		Ins.sock = socket(AF_INET, SOCK_DGRAM, 0);
		if (Ins.sock < 0) return 0;

		memset(&Ins.addr, 0, sizeof(Ins.addr));
		Ins.addr.sin_family = AF_INET;
		Ins.addr.sin_addr.s_addr = htonl(INADDR_ANY);
		Ins.addr.sin_port = htons(port);

		int optval = 1;
		setsockopt(Ins.sock, SOL_SOCKET, SO_REUSEADDR, (char*)&optval, sizeof(optval));

		if (::bind(Ins.sock, (struct sockaddr *) &Ins.addr, sizeof(Ins.addr)) < 0) {
			return 0;
		}

		if (!set_nonblock(Ins.sock, true)) {
		 	Ins.Close();
		 	return 0;
		}

		lua_pushboolean(L, true);
		return 1;
	}

	static int bReceive(lua_State* L) {
		luabind::BroadCast& Ins = bee::lua::checkudata<luabind::BroadCast>(L, 1);
		if (Ins.sock == retired_fd)
			return 0;

		socklen_t fromAddrLen = sizeof(Ins.fromAddr);
		memset(&Ins.buffer, 0, sizeof(Ins.buffer));
		int n = recvfrom(Ins.sock, Ins.buffer, sizeof(Ins.buffer), 0, (struct sockaddr *) &Ins.fromAddr, &fromAddrLen);
		if (n < 0) 
			return 0;
		
		{
			auto addr = &Ins.fromAddr;
			char tmp[sizeof "255.255.255.255"];
	#if !defined(__MINGW32__)
			const char* s = inet_ntop(AF_INET, (const void*)&((struct sockaddr_in*)addr)->sin_addr, tmp, sizeof tmp);
	#else
			const char* s = inet_ntop(AF_INET, (void*)&((struct sockaddr_in*)addr)->sin_addr, tmp, sizeof tmp);
	#endif
			lua_pushstring(L, s);
		}
		lua_pushinteger(L, ntohs(Ins.fromAddr.sin_port));
		lua_pushstring(L, Ins.buffer);
		return 3;
	}

	static int bSend(lua_State* L) {
		luabind::BroadCast& Ins = bee::lua::checkudata<luabind::BroadCast>(L, 1);
		if (Ins.sock == retired_fd) return 0;

		const char* data = luaL_checkstring(L, 2);	
		int ret = sendto(Ins.sock, data, (int)strlen(data), 0, (struct sockaddr *) &Ins.addr, sizeof(Ins.addr));
		lua_pushinteger(L, ret);
		return 1;
	}

	static int bClose(lua_State* L) {
		luabind::BroadCast& Ins = bee::lua::checkudata<luabind::BroadCast>(L, 1);
		Ins.Close();
		return 0;
	}

	static int bGetError(lua_State* L) {
		lua_pushinteger(L, get_error());
		return 1;
	}

	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"init_server", bInitServer},
			{"init_client", bInitClient},
			{"receive", bReceive},
			{"send", bSend},
			{"close", bClose},
			{"last_error", bGetError},
			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}

	static int create(lua_State* L) {
		bee::lua::newudata<luabind::BroadCast>(L);
		return 1;
	}
}

static int bGetLanIpList(lua_State* L) {
	char buffer[1024];
	gethostname(buffer, 1024);

	addrinfo hints, *res;
	int status;
	char ipstr[INET6_ADDRSTRLEN];
	memset(&hints, 0, sizeof hints); 
	hints.ai_family = AF_UNSPEC;     
	hints.ai_socktype = SOCK_STREAM;
	if ((status = getaddrinfo(buffer, NULL, &hints, &res)) != 0) {
		fprintf(stderr, "getaddrinfo: %s; hostname: %s\n", gai_strerror(status), buffer);
		return 0;
	}
	printf("get ip addresses for hostname %s:\n", buffer);
	lua_newtable(L);
	int index = 0;
	for (addrinfo *p = res; p != NULL; p = p->ai_next) {
		void *addr;
		const char *ipver;
		auto bytes = (const std::byte*)p->ai_addr;
		if (p->ai_family == AF_INET) { // IPv4
			struct sockaddr_in *ipv4 = (struct sockaddr_in*)bytes;
			addr = &(ipv4->sin_addr);
			ipver = "IPv4";
		} else { // IPv6
			struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)bytes;
			addr = &(ipv6->sin6_addr);
			ipver = "IPv6";
		}

		inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
		printf("  %s: %s\n", ipver, ipstr);

		lua_newtable(L);
		lua_pushstring(L, ipver);
		lua_setfield(L, -2, "type");
		lua_pushstring(L, ipstr);
		lua_setfield(L, -2, "ip");
		lua_seti(L, -2, ++index); 
	}
	freeaddrinfo(res); 
	printf("get end.\n");
	return 1;
}

// 得到系统中指定进程的数量
static int bGetProcessCount(lua_State* L) {
	const char* processName = luaL_checkstring(L, 1);	
	int count = 0;
#if defined(_WIN32)
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot != INVALID_HANDLE_VALUE) {
        PROCESSENTRY32 pe32;
        pe32.dwSize = sizeof(PROCESSENTRY32);
        if (Process32First(hSnapshot, &pe32)) {
            do {
                if (std::strcmp(pe32.szExeFile, processName) == 0) {
                    count++;
                }
            } while (Process32Next(hSnapshot, &pe32));
        }
        CloseHandle(hSnapshot);
    }
#endif
	lua_pushinteger(L, count);
	return 1;
}

extern "C" int luaopen_ly_net(lua_State *L) {
	lua_newtable(L);
	lua_pushcfunction(L, luabind::create);
	lua_setfield(L, -2, "CreateBroadCast");
	lua_pushcfunction(L, bGetLanIpList);
	lua_setfield(L, -2, "get_lan_ip_list");
	lua_pushcfunction(L, bGetProcessCount);
	lua_setfield(L, -2, "get_process_count");
	return 1;
}

namespace bee::lua {
	template <>
	struct udata<luabind::BroadCast> {
		static inline auto name = "luabind::BroadCast";
		static inline auto metatable = luabind::metatable;
	};
}