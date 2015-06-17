function YGridTick=CreateYGrid(Ylims,NoDivisions)

Yrange=Ylims(2)-Ylims(1);
divs=Yrange/NoDivisions;
if divs>=1          %Sets spacing to even number of nm if divisions are greater than 1nm
    SpacingY=round(Yrange/8/2)*2;
else
    SpacingY=divs;
end
YGridTick=SpacingY*floor(Ylims(1)/SpacingY):SpacingY:SpacingY*ceil(Ylims(2)/SpacingY);