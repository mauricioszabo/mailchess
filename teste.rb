require 'rvg/rvg'


rvg = Magick::RVG.new(600, 650) do |canvas|
    canvas.background_fill = 'white'

    tabuleiro = [
      [ 'TCBARBCT' ],
      [ 'PPPPPPPP' ],
      [ '        ' ],
      [ '        ' ],
      [ '        ' ],
      [ '        ' ],
      [ 'pppppppp' ],
      [ 'tcbarbct' ]
     ]
      
    SIZE = 40
    canvas.g.styles(:font => 'CONDFONT.TTF', :font_size=>SIZE) do |grp|
      grp.text( -SIZE/1.2, SIZE*0.2, '!""""""""#')
      grp.text( -SIZE/1.2, 40+SIZE, '$ + + + +%')
#      grp.text( 8, 20, "+ + + + ").styles(:font => 'CONDFONT.TTF')
#      grp.text( 8, 60, " + + + +").styles(:font => 'CONDFONT.TTF')
#      grp.text( 8, 120, "+ + + + ").styles(:font => 'CONDFONT.TTF')
#      grp.text( 8, 240, " + + + +").styles(:font => 'CONDFONT.TTF')
    end

#    canvas.rect(199, 249).styles(:fill=>'none', :stroke=>'blue')
end

rvg.draw.display
