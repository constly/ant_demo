---@class bgfx
local bgfx = {}

function bgfx.set_platform_data() end
function bgfx.init() end
function bgfx.shutdown() end

function bgfx.get_screenshot() end
function bgfx.request_screenshot() end

function bgfx.get_caps() end
function bgfx.get_stats() end
function bgfx.get_memory() end

function bgfx.reset() end
function bgfx.frame() end
function bgfx.render_frame() end

--- I: Infinitely fast hardware. When this flag is set, all rendering calls will be skipped. This is useful when profiling
---		to quickly assess potential bottlenecks between CPU and GPU;
--- P: Enable profiler;
--- S: Display internal statistics;
--- T: Display debug text;
--- W: Wireframe rendering. All rendering primitives will be rendered as lines.
---@param _flag string 可以设置的值有 "IPSTW"
function bgfx.set_debug(_flag) end
function bgfx.set_name() end

function bgfx.set_palette_color() end

--- Set view clear flags.
---@param _viewId uint16_t 视口id
---@param _flags uint16_t See: BGFX_CLEAR_*
---@param _rgba uint32_t default is 0x000000ff
---@param _depth float Depth clear value, default is 1.0f
---@param _stencil uint8_t Stencil clear value, default is 0
function bgfx.set_view_clear(_viewId, _flags, _rgba, _depth, _stencil) end
function bgfx.set_view_clear_mrt() end


--- Set view rectangle. Draw primitive outside view will be clipped.
---@param _viewId uint16_t 视口id
---@param _x uint16_t 左上角坐标
---@param _y uint16_t 左上角坐标
---@param _width uint16_t 视口宽高
---@param _height uint16_t
function bgfx.set_view_rect(_viewId, _x, _y, _width, _height) end
function bgfx.set_view_transform() end
function bgfx.set_view_order() end
function bgfx.set_view_name() end
function bgfx.set_view_frame_buffer() end

function bgfx.make_state() end
function bgfx.parse_state() end
function bgfx.make_stencil() end

function bgfx.vertex_layout() end
function bgfx.vertex_convert() end
function bgfx.export_vertex_layout() end
function bgfx.vertex_layout_stride() end

function bgfx.memory_buffer() end
function bgfx.calc_tangent() end

function bgfx.create_shader() end
function bgfx.create_program() end
function bgfx.create_vertex_buffer() end
function bgfx.create_dynamic_vertex_buffer() end
function bgfx.create_index_buffer() end
function bgfx.create_dynamic_index_buffer() end
function bgfx.create_uniform() end
function bgfx.create_texture2d() end
function bgfx.create_texturecube() end
function bgfx.create_texture3d() end
function bgfx.create_frame_buffer() end
function bgfx.create_indirect_buffer() end
function bgfx.create_occlusion_query() end
function bgfx.create_texture() end

function bgfx.destroy() end
function bgfx.get_shader_uniforms() end
function bgfx.get_uniform_info() end
function bgfx.set_view_mode() end
function bgfx.memory_texture() end


--- Clear internal debug text buffer.
---@param _attr uint8_t Background color, default is 0
---@param _small bool Default 8x16 or 8x8 font.
function bgfx.dbg_text_clear(_attr, _small) end

--- Print into internal debug text character-buffer (VGA-compatible text mode).
--- 将文本打印到内部调试文本字符缓冲区（与VGA兼容的文本模式）
---@param _x uint16_t position from top-left, 以左上角为原点
---@param _y uint16_t y的单位应该是行，x的单位应该是本行第几个字符处（反正单位肯定不是像素）
---@param _attr uint8_t Color palette. Where top 4-bits represent index of background, and bottom 4-bits represent foreground color from standard VGA text palette (ANSI escape codes).
---@param _format string printf style format.
function bgfx.dbg_text_print(_x, _y, _attr, _format, ...) end

--- Draw image into internal debug text buffer.
---@param _x uint16_t position from top-left.
---@param _y uint16_t
---@param _width uint16_t Image width and height
---@param _height uint16_t
---@param _data const void* Raw image data (character/attribute raw encoding).
---@param _pitch uint16_t Image pitch in bytes (图像的字节间距，这个参数没明白是什么意思？)
function bgfx.dbg_text_image(_x, _y, _width, _height, _data, _pitch) end

function bgfx.transient_buffer() end
function bgfx.instance_buffer() end
function bgfx.instance_buffer_metatable() end

function bgfx.is_texture_valid() end
function bgfx.get_texture() end
function bgfx.get_result() end
function bgfx.read_texture() end
function bgfx.update() end
function bgfx.update_texture2d() end
function bgfx.update_texturecube() end

function bgfx.set_uniform_command() end
function bgfx.set_uniform_matrix_command() end
function bgfx.set_uniform_vector_command() end
function bgfx.set_texture_command() end
function bgfx.set_buffer_command() end
function bgfx.set_transform_bulk() end

--- Submit an empty primitive for rendering. Uniforms and draw state
--- will be applied but no geometry will be submitted.
--- These empty draw calls will sort before ordinary draw calls.
--- 提交一个空的原始图形以进行渲染。将应用统一和绘制状态，但不会提交任何几何体。这些空的绘制调用将在普通绘制调用之前排序
---@param _viewId uint16_t 
function bgfx.touch(_viewId) end

function bgfx.submit() end
function bgfx.multi_submit() end
function bgfx.discard() end
function bgfx.set_state() end
function bgfx.set_vertex_buffer() end
function bgfx.set_index_buffer() end
function bgfx.alloc_transform_bulk() end
function bgfx.set_transform() end
function bgfx.set_transform_cached() end
function bgfx.set_uniform() end
function bgfx.set_uniform_matrix() end
function bgfx.set_uniform_vector() end
function bgfx.set_texture() end
function bgfx.blit() end
function bgfx.set_stencil() end
function bgfx.set_scissor() end
function bgfx.set_condition() end
function bgfx.submit_occlusion_query() end
function bgfx.set_buffer() end
function bgfx.dispatch() end
function bgfx.dispatch_indirect() end
function bgfx.set_instance_data_buffer() end
function bgfx.set_instance_count() end
function bgfx.submit_indirect() end
function bgfx.submit_indirect_count() end
function bgfx.execute_setter() end

function bgfx.encoder_begin() end
function bgfx.encoder_end() end
function bgfx.encoder_get() end
function bgfx.encoder_init() end
function bgfx.CINTERFACE() end