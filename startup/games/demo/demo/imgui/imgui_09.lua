local ecs = ...
local dep = require 'dep'
local ImGui = dep.ImGui
local ImGuiExtend = dep.ImGuiExtend
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_09_system",
    category        = mgr.type_imgui,
    name            = "09_自定义绘制",
    file            = "imgui/imgui_09.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

local drag_sz = { [1] = 63, min = 2, max = 100, speed = 0.2, format = "%.0f" }
local drag_thickness = { [1] = 3, min = 1, max = 8, speed = 0.05, format = "%.02f" }
local slider_ngon_sides = { [1] = 6 }
local circle_segments_override_v = { [1] = 12 }
local curve_segments_override_v = { [1] = 8 }

local circle_segments_override = false;
local curve_segments_override = false;
local colf = {1.0, 1.0, 0.4, 1.0};

function system.data_changed()
    ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
        ImGui.PushItemWidth(-ImGui.GetFontSize() * 15);
        local draw_list = ImGuiExtend.draw_list;

        -- Draw gradients
        -- (note that those are currently exacerbating our sRGB/Linear issues)
        -- Calling ImGui::GetColorU32() multiplies the given colors by the current Style Alpha, but you may pass the IM_COL32() directly as well..
        ImGui.Text("Gradients");
        local gradient_size = {x = ImGui.CalcItemWidth(), y = ImGui.GetFrameHeight() };
        do
            local p0 = {ImGui.GetCursorScreenPos()};
            local p1 = {p0[1] + gradient_size.x, p0[2] + gradient_size.y};
            local col_a = {0, 0, 0, 1};
            local col_b = {1, 1, 1, 1};
            draw_list.AddRectFilledMultiColor({min = p0, max = p1, col_upr_left = col_a, col_upr_right = col_b, col_bot_right = col_b, col_bot_left = col_a});
            ImGui.InvisibleButton("##gradient1", gradient_size.x, gradient_size.y);
        end
        do
            local p0 = {ImGui.GetCursorScreenPos()};
            local p1 = {p0[1] + gradient_size.x, p0[2] + gradient_size.y};
            local col_a = {0, 1, 0, 1};
            local col_b = {1, 0, 0, 1};
            draw_list.AddRectFilledMultiColor({min = p0, max = p1, col_upr_left = col_a, col_upr_right = col_b, col_bot_right = col_b, col_bot_left = col_a});
            ImGui.InvisibleButton("##gradient2", gradient_size.x, gradient_size.y);
        end

        -- Draw a bunch of primitives
        ImGui.Text("All primitives");
        ImGui.DragFloat("Size", drag_sz);
        ImGui.DragFloat("Thickness", drag_thickness);
        ImGui.SliderInt("N-gon sides", slider_ngon_sides, 3, 12);
        local change, v = ImGui.Checkbox("##circlesegmentoverride", {circle_segments_override});
        if change then
            circle_segments_override = v 
        end 
        ImGui.SameLine(0.0, 5);
        if ImGui.SliderInt("Circle segments override", circle_segments_override_v, 3, 40) then 
            circle_segments_override = true
        end
        local change, v = ImGui.Checkbox("##curvessegmentoverride", {curve_segments_override});
        if change then
            curve_segments_override = v 
        end
        ImGui.SameLine(0.0, 5);
        if ImGui.SliderInt("Curves segments override", curve_segments_override_v, 3, 40) then 
            curve_segments_override = true
        end
        ImGui.ColorEdit4("Color", colf, ImGui.ColorEditFlags { "None" });

        local p = {ImGui.GetCursorScreenPos()};
        local col = { table.unpack(colf) };
        local spacing = 10.0;
        local corners_tl_br = ImGui.DrawFlags {"RoundCornersTopLeft", "RoundCornersBottomRight"};
        local rounding = drag_sz[1] / 5.0;
        local circle_segments = circle_segments_override and circle_segments_override_v[1] or 0;
        local curve_segments = curve_segments_override and curve_segments_override_v[1] or 0;
        local x = p[1] + 4.0;
        local y = p[2] + 4.0;
        local sz = drag_sz[1]
        local thickness = drag_thickness[1]
        local ngon_sides = slider_ngon_sides[1]
        for n = 0, 1, 1 do 
            -- First line uses a thickness of 1.0f, second line uses the configurable thickness
            local th = (n == 0) and 1.0 or thickness;
            draw_list.AddNgon({center = {x + sz*0.5, y + sz*0.5}, radius = sz*0.5, col = col, segments = ngon_sides, thickness = th});         
            x = x + sz + spacing; -- N-gon

            draw_list.AddCircle({center = {x + sz*0.5, y + sz*0.5}, radius = sz*0.5, col = col, segments = circle_segments, thickness = th});          
            x = x + sz + spacing;  -- Circle

            draw_list.AddEllipse({center = {x + sz*0.5, y + sz*0.5}, radius_x = sz*0.5, radius_y = sz*0.3, col = col, rot = -0.3, segments = circle_segments, thickness= th}); 
            x = x + sz + spacing;	-- Ellipse
            
            draw_list.AddRect({min = {x, y}, max = {x + sz, y + sz},  col = col, rounding = 0.0, flags = 0, thickness = th});          
            x = x + sz + spacing;  -- Square
            
            draw_list.AddRect({min = {x, y}, max = {x + sz, y + sz}, col = col, rounding = rounding, flags = 0, thickness = th});      
            x = x + sz + spacing;  -- Square with all rounded corners
            
            draw_list.AddRect({min = {x, y}, max = {x + sz, y + sz}, col = col, rounding = rounding, flags = corners_tl_br, thickness = th});         
            x = x + sz + spacing;  -- Square with two rounded corners
            
            draw_list.AddTriangle({p1 = {x + sz*0.5, y}, p2 = {x + sz, y + sz - 0.5}, p3 = {x, y + sz - 0.5}, col = col, thickness = th});
            x = x + sz + spacing;  -- Triangle
            
            --draw_list->AddTriangle(ImVec2(x+sz*0.2f,y), ImVec2(x, y+sz-0.5f), ImVec2(x+sz*0.4f, y+sz-0.5f), col, th);x+= sz*0.4f + spacing; // Thin triangle
            draw_list.AddLine({p1 = {x, y}, p2 = {x + sz, y}, col = col, thickness = th});                                       
            x = x + sz + spacing;  -- Horizontal line (note: drawing a filled rectangle will be faster!)
            
            draw_list.AddLine({p1 = {x, y}, p2 = {x, y + sz}, col = col, thickness = th});                                       
            x = x + spacing;       -- Vertical line (note: drawing a filled rectangle will be faster!)
            
            draw_list.AddLine({p1 = {x, y}, p2 = {x + sz, y + sz}, col = col, thickness = th});                                  
            x = x + sz + spacing;  -- Diagonal line

            -- Quadratic Bezier Curve (3 control points)
            local cp3 = { {x, y + sz * 0.6}, {x + sz * 0.5, y - sz * 0.4}, {x + sz, y + sz} };
            draw_list.AddBezierQuadratic({p1 = cp3[1], p2 = cp3[2], p3 = cp3[3], col = col, thickness = th, segments = curve_segments}); 
            x = x + sz + spacing;

            -- Cubic Bezier Curve (4 control points)
            local cp4 = { {x, y}, {x + sz * 1.3, y + sz * 0.3}, {x + sz - sz * 1.3, y + sz - sz * 0.3}, {x + sz, y + sz} };
            draw_list.AddBezierCubic(cp4[0], cp4[1], cp4[2], cp4[3], col, th, curve_segments);

            x = p[1] + 4;
            y = y + sz + spacing;
        end

        draw_list.AddNgonFilled({center = {x + sz * 0.5, y + sz * 0.5}, radius = sz * 0.5, col = col, segments = ngon_sides});             
        x = x + sz + spacing;  -- N-gon

        draw_list.AddCircleFilled({center = {x + sz * 0.5, y + sz * 0.5}, radius = sz * 0.5, col = col, segments = circle_segments});
        x = x + sz + spacing;  -- Circle
        
        draw_list.AddEllipseFilled({center = {x + sz * 0.5, y + sz * 0.5}, radius_x = sz * 0.5, radius_y = sz * 0.3, col = col, rot = -0.3, segments = circle_segments}); 
        x = x + sz + spacing; -- Ellipse
        
        draw_list.AddRectFilled({min = {x, y}, max = {x + sz, y + sz}, col = col});                                    
        x = x + sz + spacing;  -- Square
        
        draw_list.AddRectFilled({min = {x, y}, max = {x + sz, y + sz}, col = col, rounding = 10});                             
        x = x + sz + spacing;  -- Square with all rounded corners
        
        draw_list.AddRectFilled({min = {x, y}, max = {x + sz, y + sz}, col = col, rounding = 10.0, flags = corners_tl_br});              
        x = x + sz + spacing;  -- Square with two rounded corners
        
        draw_list.AddTriangleFilled({p1 = {x+sz*0.5,y}, p2 = {x+sz, y+sz-0.5}, p3 = {x, y+sz-0.5}, col = col});  
        x = x + sz + spacing;  -- Triangle
        
        -- draw_list->AddTriangleFilled(ImVec2(x+sz*0.2f,y), ImVec2(x, y+sz-0.5f), ImVec2(x+sz*0.4f, y+sz-0.5f), col); x += sz*0.4f + spacing; // Thin triangle
        draw_list.AddRectFilled({min = {x, y}, max = {x + sz, y + thickness}, col = col });                             
        x = x + sz + spacing;  -- Horizontal line (faster than AddLine, but only handle integer thickness)
        
        draw_list.AddRectFilled({min = {x, y}, max = {x + thickness, y + sz}, col = col });                             
        x = x + spacing * 2.0; -- Vertical line (faster than AddLine, but only handle integer thickness)
        
        draw_list.AddRectFilled({min = {x, y}, max = {x + 1, y + 1}, col = col});                                      
        x = x + sz;            -- Pixel (faster than AddLine)
        
        draw_list.AddRectFilledMultiColor({min = {x, y}, max = {x + sz, y + sz}, col_upr_left = {0, 0, 0, 1}, col_upr_right = {1, 0, 0, 1}, 
                col_bot_right = {1, 1, 0, 1}, col_bot_left = {0, 1, 0, 1}});

        y = y + sz + spacing;
        x = p[1] + 4;
        draw_list.AddText({pos = {x, y}, col = col, text = "使用 draw_list.AddText 绘制"})
        ImGui.Dummy((sz + spacing) * 11.2, (sz + spacing) * 3.0);
        ImGui.PopItemWidth();
    end
    ImGui.End()
end