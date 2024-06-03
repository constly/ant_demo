---@class bgfx.debug.type 调试类型，有五类，见下面注释
---@field value IWSTP
--[[
#define BGFX_DEBUG_NONE                           UINT32_C(0x00000000) //!< No debug.
#define BGFX_DEBUG_WIREFRAME                      UINT32_C(0x00000001) //!< Enable wireframe for all primitives.

/// Enable infinitely fast hardware test. No draw calls will be submitted to driver.
/// It's useful when profiling to quickly assess bottleneck between CPU and GPU.
#define BGFX_DEBUG_IFH                            UINT32_C(0x00000002)
#define BGFX_DEBUG_STATS                          UINT32_C(0x00000004) //!< Enable statistics display.
#define BGFX_DEBUG_TEXT                           UINT32_C(0x00000008) //!< Enable debug text display.
#define BGFX_DEBUG_PROFILER                       UINT32_C(0x00000010) //!< Enable profiler. This causes per-view statistics to be collected, available through `bgfx::Stats::ViewStats`. This is unrelated to the profiler functions in `bgfx::CallbackI`.
--]]