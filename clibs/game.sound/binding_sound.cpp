#define CUTE_SOUND_IMPLEMENTATION
#include "cute_sound.h"
#include <lua.hpp>
#include <string>
#include <map>
#include <bee/lua/binding.h>

struct CuteSoundMgr {
	int64_t max_id = 0;

	// 当前缓存的资源列表
	std::map<std::string, cs_audio_source_t*> assets;

	// 播放的声音 (每隔一段时间更新一次，更新时会把已经播放完毕的移除)
	std::map<int64_t, cs_playing_sound_t> sounds;

	int64_t register_sound(const cs_playing_sound_t& sound) {
		auto id = ++max_id;
		sounds.insert(std::make_pair(id, sound));
		return id;
	}

	cs_playing_sound_t* get_sound(int64_t id) {
		auto it = sounds.find(id);
		return it != sounds.end() ? &it->second : nullptr;
	}

	cs_audio_source_t* get_audio_source(const char* path) {
		auto it = assets.find(path);
		if (it == assets.end()) {
			cs_audio_source_t* wav = cs_load_wav(path, NULL);
			if (!wav) {
				printf("failed to load wav, path = %s\n", path);
			}
			assets.insert(std::make_pair(path, wav));
			return wav;
		}
		return it->second;
	}

};

namespace bind::CuteSound {

	//----------------------------------------------------------
	// 全局接口
	//----------------------------------------------------------
	static int sInit(lua_State* L) {
		void* os_handle = nullptr;
#if CUTE_SOUND_PLATFORM == CUTE_SOUND_WINDOWS
		os_handle = GetConsoleWindow();
#endif
		auto ret = cs_init(os_handle, 44100, 1024, NULL);
		if (ret != CUTE_SOUND_ERROR_NONE) {
			printf("failed to init sound mgr, error code = %d\n", ret);
		}
		return 0;
	}

	// 每帧更新
	static int sUpdate(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto delta_time = (float)luaL_checknumber(L, 2);
		cs_update(delta_time);
		return 0;
	}

	static int sPreload(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		cs_audio_source_t* jump = cs_load_wav(path, NULL);
		return 0;
	}

	static int sUnload(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		return 0;
	}

	static int sUnloadAll(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		return 0;	
	}

	//----------------------------------------------------------
	// music 接口
	//----------------------------------------------------------



	//----------------------------------------------------------
	// sound 接口
	//----------------------------------------------------------
	// 播放声音 
	// 参数1: 声音全路径 (打完包后，声音资源在包内....)
	// 参数2: 是否循环播放
	// 返回: 声音id
	static int sPlaySound(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		cs_audio_source_t* wav = mgr.get_audio_source(path);
		if (wav) {
			cs_sound_params_t params;
			params.paused = false;
			params.looped = (bool)!!lua_toboolean(L, 3);
			params.volume = 1.0f;
			params.pan = 0.5f;
			params.delay = 0.0f;
			auto sound = cs_play_sound(wav, params);
			auto id = mgr.register_sound(sound);
			lua_pushinteger(L, id);
		} else {
			lua_pushinteger(L, 0);
		}
		return 1;
	}

	// cs_play_sound(jump, params);
	// cs_free_audio_source(jump);
	// cs_ref_count

	// 停止声音播放, 传入声音id
	static int sStopSound(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = luaL_checkinteger(L, 2);
		auto sound = mgr.get_sound(id);
		if (sound) {

		}
		return 0;
	}

	// 暂停
	static int sPauseSound(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);

		return 0;
	}

	// 继续
	static int sResumeSound(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);

		return 0;
	}


	static int sEmpty(lua_State* L) {
		return 0;
	}

	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			// global
			{ "Init", 					sInit },
			{ "SetGlobalVolume", 		sEmpty },
			{ "SetPause", 				sEmpty },
			{ "SetPan", 				sEmpty }, // 声相, 0-1 表示从左声道到右声道, 0.5表示在中间
			{ "Update", 				sUpdate },

			// 声音预加载 / 卸载
			{ "Preload", 				sPreload },
			{ "Unload", 				sUnload },
			{ "UnloadAll", 				sUnloadAll },

			// music 
			{ "PlayMusic", 			sEmpty },
			{ "SwitchToMusic", 		sEmpty },
			{ "CrossFadeMusic", 	sEmpty },
			{ "StopMusic", 			sEmpty },
			{ "PauseMusic", 		sEmpty },
			{ "ResumeMusic", 		sEmpty },
			{ "SetMusicVolume", 	sEmpty },
			{ "SetMusicLoop", 		sEmpty },

			// sound
			{ "PlaySound", 			sPlaySound },
			{ "StopSound", 			sStopSound },
			{ "StopAllSound", 		sEmpty },
			{ "IsSoundPlaying", 	sEmpty },
			{ "PauseSound", 		sPauseSound },
			{ "ResumeSound", 		sResumeSound },
			{ "SetSoundVolume", 	sEmpty },
			{ "SetSoundLoop", 		sEmpty },
			{ "SetSoundPause", 		sEmpty },
			
			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}

	static int getmetatable(lua_State* L) {
		bee::lua::getmetatable<CuteSoundMgr>(L);
        return 1;
	}

	static int create(lua_State* L) {
		bee::lua::newudata<CuteSoundMgr>(L);
		return 1;
	}
};

static int create_sound_mgr(lua_State* L) {
	return bind::CuteSound::create(L);
}

extern "C" int luaopen_game_sound(lua_State *L) {
	lua_newtable(L);

	// sound mgr 全局只能有一个
	lua_pushcfunction(L, create_sound_mgr);
	lua_setfield(L, -2, "CreateSoundMgr");
	return 1;
}

namespace bee::lua {
	template <>
	struct udata<CuteSoundMgr> {
		static inline auto name = "CuteSoundMgr";
		static inline auto metatable = bind::CuteSound::metatable;
	};
}