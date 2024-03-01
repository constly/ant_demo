#define CUTE_SOUND_IMPLEMENTATION
#include "cute_sound.h"
#include <lua.hpp>
#include <string>
#include <map>
#include <bee/lua/binding.h>
#include "fastio.h"

struct CuteSoundMgr {	
	// audio list
	std::map<std::string, cs_audio_source_t*> assets;

	// 播放的声音 (每隔一段时间更新一次，更新时会把已经播放完毕的移除)
	// 
	std::map<int64_t, cs_playing_sound_t> sounds;

	int64_t register_sound(const cs_playing_sound_t& sound) {
		auto id = sound.id;
		sounds.insert(std::make_pair(id, sound));
		return id;
	}

	cs_playing_sound_t* get_sound(int64_t id) {
		auto it = sounds.find(id);
		return it != sounds.end() ? &it->second : nullptr;
	}

	cs_audio_source_t* get_audio_source(const char* path) {
		auto it = assets.find(path);
		return it != assets.end() ? it->second : nullptr;
	}

};

namespace bind::CuteSound {

	//----------------------------------------------------------
	// 全局接口
	//----------------------------------------------------------
	static int sInit(lua_State* L) {
		void* os_handle = nullptr;
#if CUTE_SOUND_PLATFORM == CUTE_SOUND_WINDOWS
		/*
			注意: 这里代码是有问题的
			GetForegroundWindow 返回的是操作系统中当前激活的窗口，不一定是本程序的渲染窗口 (取决于代码执行到这里时，用户的焦点窗口在哪里)
			假如GetForegroundWindow()返回的是其他窗口，并且其他窗口被销毁后，不清楚会有什么表现
		*/ 
		os_handle = GetForegroundWindow();
#endif
		auto ret = cs_init(os_handle, 44100, 1024, NULL);
		if (ret != CUTE_SOUND_ERROR_NONE) {
			printf("failed to init sound mgr, error code = %d\n", ret);
		}
		return 0;
	}

	static int sSetGlobalVolume(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto volume_0_to_1 = (float)luaL_checknumber(L, 2);
		cs_set_global_volume(volume_0_to_1);
		return 0;
	}

	static int sSetPause(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto true_for_paused = !!lua_toboolean(L, 2);
		cs_set_global_pause(true_for_paused);
		return 0;
	}

	static int sSetPan(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto pan_0_to_1 = (float)luaL_checknumber(L, 2);
		cs_set_global_pan(pan_0_to_1);
		return 0;
	}
	
	static int sUpdate(lua_State* L) {
		auto& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto delta_time = (float)luaL_checknumber(L, 2);
		cs_update(delta_time);
		return 0;
	}

	static int sShutdown(lua_State* L) {
		cs_shutdown();
		return 0;
	}

	static int sPreload(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		auto mem = getmemory(L, 3);
		auto it = mgr.assets.find(path);
		if (it == mgr.assets.end()) {
			cs_error_t err = CUTE_SOUND_ERROR_NONE;
			cs_audio_source_t* audio = cs_read_mem_wav(mem.data(), mem.size(), &err);
			if (err != CUTE_SOUND_ERROR_NONE) {
				printf("failed to read mem wav, error code = %d\n", err);
			} else {
				mgr.assets.insert(std::make_pair(path, audio));
			}
		}
		return 0;
	}

	static int sIsPreload(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		auto it = mgr.assets.find(path);
		lua_pushboolean(L, it == mgr.assets.end() ? false : true);
		return 1;
	}

	static int sUnload(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		auto it = mgr.assets.find(path);
		if (it != mgr.assets.end()) {
			cs_free_audio_source(it->second);
			mgr.assets.erase(it);
		}
		return 0;
	}

	static int sUnloadAll(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		for(auto& one : mgr.assets) {
			cs_free_audio_source(one.second);
		}
		mgr.assets.clear();
		return 0;	
	}

	//----------------------------------------------------------
	// music api
	//----------------------------------------------------------
	static int sPlayMusic(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		auto asset = mgr.get_audio_source(path);
		if (asset) {
			auto fade_in_time = (float)luaL_checknumber(L, 3);
			cs_music_play(asset, fade_in_time);
		}
		return 0;
	}

	static int sStopMusic(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto fade_out_time = (float)luaL_checknumber(L, 2);
		cs_music_stop(fade_out_time);
		return 0;
	}

	static int sSwitchToMusic(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		auto asset = mgr.get_audio_source(path);
		if (asset) {
			auto fade_out_time = (float)luaL_checknumber(L, 3);
			auto fade_in_time = (float)luaL_checknumber(L, 4);
			cs_music_switch_to(asset, fade_out_time, fade_in_time);
		}
		return 0;
	}

	static int sCrossFadeMusic(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		auto asset = mgr.get_audio_source(path);
		if (asset) { 
			auto cross_fade_time = (float)luaL_checknumber(L, 3);
			cs_music_crossfade(asset, cross_fade_time);
		}
		return 0;
	}

	static int sPauseMusic(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		cs_music_pause();
		return 0;
	}

	static int sResumeMusic(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		cs_music_resume();
		return 0;
	}

	static int sSetMusicVolume(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto volume_0_to_1 = (float)luaL_checknumber(L, 2);
		cs_music_set_volume(volume_0_to_1);
		return 0;
	}

	static int sSetMusicLoop(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		auto true_to_loop = !!lua_toboolean(L, 2);
		cs_music_set_loop(true_to_loop);
		return 0;
	}

	//----------------------------------------------------------
	// sound api
	//----------------------------------------------------------
	static int sPlaySound(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		const char* path = luaL_checkstring(L, 2);
		bool loop = (bool)!!lua_toboolean(L, 3);
		float volume = (float)luaL_optnumber(L, 4, 1);
		float pan = (float)luaL_optnumber(L, 5, 0.5);
		cs_audio_source_t* wav = mgr.get_audio_source(path);
		if (wav) {
			cs_sound_params_t params;
			params.paused = false;
			params.looped = loop;
			params.volume = volume;
			params.pan = pan;
			params.delay = 0.0f;
			auto sound = cs_play_sound(wav, params);
			auto id = mgr.register_sound(sound);
			lua_pushinteger(L, id);
			return 1;
		} 
		return 0;
	}

	static int sStopSound(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		if (sound) {

		}
		return 0;	
	}

	static int sStopAllSound(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		cs_stop_all_playing_sounds();
		return 0;
	}

	static int sIsSoundPlaying(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		return sound && cs_sound_is_active(*sound);
	}

	static int sIsSoundPause(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		return sound && cs_sound_get_is_paused(*sound);
	}

	static int sIsSoundLoop(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		return sound && cs_sound_get_is_looped(*sound);
	}

	static int sGetSoundVolume(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		if (sound) {
			float volume =  cs_sound_get_volume(*sound);
			lua_pushnumber(L, volume);
			return 1;
		}
		return 0;
	}

	static int sSetSoundPause(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		bool true_for_paused = !!lua_toboolean(L, 3);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		if (sound) 
			cs_sound_set_is_paused(*sound, true_for_paused);
		return 0;
	}

	static int sSetSoundVolume(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		float volume_0_to_1 = (float)luaL_checknumber(L, 3);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		if (sound) 
			cs_sound_set_volume(*sound, volume_0_to_1);
		return 0;
	}

	static int sSetSoundLoop(lua_State* L) {
		CuteSoundMgr& mgr = bee::lua::checkudata<CuteSoundMgr>(L, 1);
		int64_t id = (int64_t)luaL_checkinteger(L, 2);
		bool true_for_looped = !!lua_toboolean(L, 3);
		cs_playing_sound_t* sound = mgr.get_sound(id);
		if (sound) 
			cs_sound_set_is_looped(*sound, true_for_looped);
		return 0;
	}

	//----------------------------------------------------------
	// metatable
	//----------------------------------------------------------
	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			// global
			{ "Init", 					sInit },
			{ "SetGlobalVolume", 		sSetGlobalVolume },
			{ "SetPause", 				sSetPause },
			{ "SetPan", 				sSetPan }, 
			{ "Update", 				sUpdate },
			{ "Shutdown",				sShutdown },

			// load / unload
			{ "Preload", 				sPreload },
			{ "IsPreload", 				sIsPreload },
			{ "Unload", 				sUnload },
			{ "UnloadAll", 				sUnloadAll },

			// music 
			{ "PlayMusic", 			sPlayMusic },
			{ "SwitchToMusic", 		sSwitchToMusic },
			{ "CrossFadeMusic", 	sCrossFadeMusic },
			{ "StopMusic", 			sStopMusic },
			{ "PauseMusic", 		sPauseMusic },
			{ "ResumeMusic", 		sResumeMusic },
			{ "SetMusicVolume", 	sSetMusicVolume },
			{ "SetMusicLoop", 		sSetMusicLoop },

			// sound
			{ "PlaySound", 			sPlaySound },
			{ "StopSound", 			sStopSound },
			{ "StopAllSound", 		sStopAllSound },
			{ "IsSoundPlaying", 	sIsSoundPlaying },
			{ "IsSoundPause", 		sIsSoundPause },
			{ "IsSoundLoop", 		sIsSoundLoop },
			{ "GetSoundVolume", 	sGetSoundVolume },
			{ "SetSoundPause", 		sSetSoundPause },
			{ "SetSoundVolume", 	sSetSoundVolume },
			{ "SetSoundLoop", 		sSetSoundLoop },
			
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

extern "C" int luaopen_ly_sound_impl(lua_State *L) {
	lua_newtable(L);

	// sound mgr, 全局唯一
	// 
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