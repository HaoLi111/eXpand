function d_e(p1, p2)
    return sqrt(sum((p1 .- p2).^2))
end
function solve_angle_cos(a,b,c)
    #c2 = a2 + b2 – 2ab cos ∠z using cos rule, solve the angle (positive)
    return acos((a^2+b^2-c^2)/(2*a*b))
end
function expand_par(point_bottom_left::Array, point_bottom_right::Array, point_top_left, point_top_right;
    projection_left = [0,0],projection_right = [1,0],base_angle_left=0,base_angle_right=pi)
    # expanding surface with 4-gon with vertices on the same plane
    d_base = d_e(point_bottom_left,point_bottom_right)
    d_left = d_e(point_bottom_left,point_top_left)
    d_right = d_e(point_bottom_right,point_top_right)
    d_left_angle = d_e(point_bottom_right,point_top_left)
    d_right_angle = d_e(point_bottom_left,point_top_right)
    
    angle_left  = solve_angle_cos(d_base,d_left,d_left_angle)
    angle_right = solve_angle_cos(d_base,d_right,d_right_angle)
    
    projection_top_left = projection_left + [cos(angle_left+base_angle_left) , sin(angle_left+base_angle_left)] .* d_left
    projection_top_right = projection_right + [cos(-angle_right+base_angle_right) , sin(-angle_right+base_angle_right)] .* d_right


    d_base_top = d_e(projection_top_left,projection_top_right)
    d_top_left_angle = d_e(projection_top_right,projection_left)
    d_top_right_angle = d_e(projection_top_left,projection_right)
    angle_top_left = solve_angle_cos(d_base_top,d_left,d_top_left_angle)
    angle_top_right = solve_angle_cos(d_right,d_base_top,d_top_right_angle)
    angle_new_left = base_angle_left+angle_left-(pi-angle_top_left)
    angle_new_right = base_angle_right-angle_right+(pi-angle_top_right)
    return Dict("p_left" =>projection_top_left,"p_right"=>projection_top_right,"angle_new_left" => angle_new_left,"angle_top_right"=>angle_new_right)

end



function expand_tri(point_bottom_left::Array, point_bottom_right::Array, point_top::Array;
    projection_left = [0,0],projection_right = [1,0],base_angle_left=0,base_angle_right=pi)
    # expanding surface with triangles
    # does not require 4-gons with parallel surfaces
    d_base = d_e(point_bottom_left,point_bottom_right)
    d_left = d_e(point_bottom_left,point_top)
    d_right = d_e(point_bottom_right,point_top)
    d_left_angle = d_right
    d_right_angle = d_left
    
    angle_left  = solve_angle_cos(d_base,d_left,d_left_angle)
    angle_right = solve_angle_cos(d_base,d_right,d_right_angle)
    angle_top = pi - angle_left - angle_right

    projection_top = projection_left + [cos(angle_left+base_angle_left) , sin(angle_left+base_angle_left)] .* d_left
    angle_left_top = base_angle_left + angle_left
    angle_right_top = base_angle_right-angle_right
    return Dict("p_top"=>projection_top,"angle_new_left" => angle_left_top,"angle_new_right" => angle_right_top)
end



function expand_seq_4gon(seq_left,seq_right;
    projection_left = [0,0],projection_right = [1,0],base_angle_left=0,base_angle_right=pi)
    n=length(seq_left)
    s_left = zeros(2,n)
    s_right = zeros(2,n)
    s_left[:,1] = projection_left
    s_right[:,1] = projection_right

    for i in 2:n
        result = expand_par(seq_left[:,i-1],seq_right[:,i-1],seq_left[:,i],seq_right[:,i],
        projection_left=projection_left,projection_right=projection_right,base_angle_left=base_angle_left,base_angle_right=base_angle_right)
        projection_left = result["p_left"]
        projection_right = result["p_right"]
        s_left[:,i] = projection_left
        s_right[:,i] = projection_right
        base_angle_left = result["angle_new_left"]
        base_angle_right = result["angle_new_right"]
    end

    return Dict("s_left"=>s_left,"s_right"=>s_right)
end



expand_par([0,0,0],[0,0,1],[0,1,0],[0,1,1])

expand_tri([0,0,0],[0,0,1],[0,1,0])

expand_tri([0,1,0],[0,0,1],[1,0,0],projection_left=[0,0],projection_right=[0,sqrt(2)])
pi/3
2*pi/3