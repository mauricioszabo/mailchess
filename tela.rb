#!/usr/bin/env ruby

require 'rvg/rvg'
require 'tabuleiro.rb'

FONT_SIZE = 40


# !""""""""#
# $tMvWlVmT%
# $OoOoOoOo%
# $ + + + +%
# $+ + + + %
# $ + + + +%
# $+ + + + %
# $pPpPpPpP%
# $RnBqKbNr%

class Tela
  attr_reader :codigo_jogo
  def emails
    return [@tabuleiro.player1, @tabuleiro.player2]
  end

  def cor_vez
    if(@tabuleiro.vez)
      return "Brancas"
    else
      return "Pretas"
    end
  end

  def email
    if(@tabuleiro.vez)
      return @tabuleiro.player1
    else
      return @tabuleiro.player2
    end
  end

  def convert(char)
    case char
      when 'T': return 't'
      when 'C': return 'm'
      when 'B': return 'v'
      when 'R': return 'l'
      when 'D': return 'w'
      when 'P': return 'o'
      when 'p': return 'p'
      when 't': return 'r'
      when 'c': return 'n'
      when 'b': return 'b'
      when 'r': return 'k'
      when 'd': return 'q'
    end
    return ' '
  end

  def initialize(codigo_jogo = 0, p1 = '', p2 = '')
    if(codigo_jogo == 0)
      codigo_jogo = novo_jogo
    end

    @tabuleiro = Tabuleiro.novo(codigo_jogo, p1, p2)
    @codigo_jogo = codigo_jogo
  end

  def desenha(erros = [], x1=nil, y1=nil)
    tab = Magick::RVG.new(FONT_SIZE*10, FONT_SIZE*11) do |canvas|
      canvas.background_fill = 'white'
      canvas.g.styles(:font => 'condfont.ttf', :font_size=>FONT_SIZE) do |g|
        g.text(0, FONT_SIZE, "!#{'"' * 8}#")

        8.times do |y|
          g.text(0, FONT_SIZE * (y+2), "$")
          g.text(FONT_SIZE*9, FONT_SIZE * (y+2), "%")
        end
        g.text(0, FONT_SIZE*10, "/#{'(' * 8})")

        8.times do |x|
          8.times do |y|
            letra = convert(@tabuleiro[y][x].chr)

            unless(x % 2 == y % 2)
              if(letra == ' ')
                letra = '+'
              else
                letra.upcase!
              end
            end

            g.text((x+1)*FONT_SIZE, (y+2)*FONT_SIZE, letra)
          end
        end

        canvas.g.styles(:font => 'Times', :font_size=>22) do |g|
          letra = 'A'
          8.times do |v|
            g.text( (v+1) * FONT_SIZE + 15, 22, letra)
            letra = letra.next
            g.text( 12, (v+1) * FONT_SIZE + 25, (v+1).to_i)
          end

          erro_y = FONT_SIZE * 9 + 16 * 2
          erros.each do |erro|
            g.text(30, erro_y, erro).styles(:font_size => 16, :font_style=>'bold', :fill=>'red')
            erro_y += 16
          end
        end

        #p ultima_jogada
        #p canvas.class
        if(x1)
          p x1, y1
          x = (x1 + 1) * FONT_SIZE
          y = (y1 + 1) * FONT_SIZE

          canvas.rect(FONT_SIZE, FONT_SIZE, x, y).styles(:fill=>'none', :stroke=>'blue')
        end
      end
    end

    d = tab.draw
    d.format = 'jpg'

    return d
  end

  #Vê uma entrada vazia, e cria um novo jogo.
  def novo_jogo
    1.upto 10000 do |i|
      arquivo = "#{File.dirname($0)}/#{i}.jogo"
      return i unless(File.exists?(arquivo))
    end

    raise "Erro: todos os slots do jogo estão ocupados."
  end

  #Move as peças, salva e depois desenha
  def mover(movimento)
    retorno, x, y = @tabuleiro.mover(movimento)
    @tabuleiro.salvar unless(retorno.nil?)
    tab = desenha(@tabuleiro.erros, x, y)

    return tab, retorno
  end

  def jogadas
    return @tabuleiro.todas_jogadas
  end

  def vez_correta?(email)
    if(@tabuleiro.vez and email == @tabuleiro.player1)
      return true
    elsif(!@tabuleiro.vez and email == @tabuleiro.player2)
      return true
    else
      return false
    end
  end
end

if($0 == __FILE__)
  a = Tela.new(666)
  a.desenha.display
#
# comandos = [
#   'f6', 'e4', 'g5', 'Dh5'
# ]
#
  $stdin.each do |char|
  # comandos.each do |char|
     imagem, ret = a.mover(char)
#
    p ret
    imagem.display
    if(ret =~ /([0O]-1|1-[0O])/)
      puts "FIM DE JOGO!"
      puts a.jogadas.join("\n")
      break
    end
  end
end

#    canvas.g.styles(:font => 'CONDFONT.TTF', :font_size=>SIZE) do |grp|
#      grp.text( -SIZE/1.2, SIZE*0.2, '!""""""""#')
#      grp.text( -SIZE/1.2, 40+SIZE, '$ + + + +%')
#      grp.text( 8, 20, "+ + + + ").styles(:font => 'CONDFONT.TTF')
#      grp.text( 8, 60, " + + + +").styles(:font => 'CONDFONT.TTF')
#      grp.text( 8, 120, "+ + + + ").styles(:font => 'CONDFONT.TTF')
#      grp.text( 8, 240, " + + + +").styles(:font => 'CONDFONT.TTF')
#    end

#    canvas.rect(199, 249).styles(:fill=>'none', :stroke=>'blue')
#end

# rvg.draw.display
