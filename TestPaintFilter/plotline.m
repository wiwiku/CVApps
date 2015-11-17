function plotline(pt1, pt2, varargin)    
    if nargin > 0
        color = varargin{1};
    else
        color = 'b';
    end
    scale = 100;
    pt3 = pt2 + scale * (pt2 - pt1);
    pt4 = pt2 - scale * (pt2 - pt1);
    pts = [pt3; pt4];
    plot(pts(:,1), pts(:,2), 'LineWidth', 2, 'Color', color);
end