---@class blueprint_ed
local ed = {}

---@alias ed.PinType
---| `ed.PinType.Flow`
---| `ed.PinType.Bool`
---| `ed.PinType.Int`
---| `ed.PinType.Float`
---| `ed.PinType.String`
---| `ed.PinType.Object`
---| `ed.PinType.Function`
---| `ed.PinType.Delegate`
ed.PinType = {}

---@class blueprint_ed.PinKind
---@field Input number
---@field Output number
ed.PinKind = {}


---@class blueprint_node_pin_tpl_data -- 节点模板pin声明
---@field type string					pin类型, 有 input_flow, output_flow, input_var, output_var
---@field name string					pin名字  
---@field data_type	string 				数据类型
---@field data_default  string 			数据默认值
---@field meta table<string, string>	其他数据
local blueprint_node_pin_tpl_data = {}

---@class blueprint_node_tpl_data 节点模板声明
---@field name string               						节点名字
---@field attrs sims.server.map                							属性列表
---@field pins blueprint_node_pin_tpl_data[]                pin列表
---@field show_type string 									节点显示类型
---@field groups sims.server.map										分组信息
---@field size_x number 									大小x - 可选
---@field size_y number 									大小y - 可选
---@field header_color number[]								节点头部颜色
local blueprint_node_tpl_data = {}

---@class blueprint_node_pin_data
---@field id number			唯一id
---@field type ed.PinType  		
---@field kind ed.PinKind 		
---@field key string  		关键字
---@field value string 		数据
local blueprint_node_pin_data = {}


---@class blueprint_node_data 节点编辑器数据
---@field id number									唯一id
---@field tplId string								模板名
---@field pos_x number								位置x
---@field pos_y number								位置y
---@field size_x number								大小x (只有部分节点有点大小)
---@field size_y number								大小y
---@field inputs blueprint_node_pin_data[]			输入流
---@field outputs blueprint_node_pin_data[]			输出流
---@field delegates blueprint_node_pin_data[] 		回调列表
local blueprint_node_data = {}


---@class blueprint_link_data 节点连线数据
---@field id number 								唯一id 
---@field startPin number							初始点
---@field endPin number								结束点
---@field type ed.PinType							线条类型
local blueprint_link_data = {}

---@class node_editor_create_args 编辑器创建参数说明
---@field type string 							图的类型
---@field graph_count number					图数量
---@field blueprint_builder blueprint_builder 	节点声明列表
local node_editor_create_args = {}