require 'rvg/rvg'


class Tabuleiro
  attr_accessor :vez
  attr_accessor :player1
  attr_accessor :player2
  attr_reader :erros
  attr_reader :todas_jogadas

  def self.novo(codigo_jogo, p1 = '', p2 = '')
    @arquivo = "#{File.dirname($0)}/#{codigo_jogo}.jogo"
    if(File.exist? @arquivo)
      return YAML.load_file(@arquivo)
    else
      return self.new(codigo_jogo, p1, p2)
    end
  end

  def initialize(codigo_jogo, p1 = '', p2 = '')
    @vitoria = nil
    @vez = true #Brancas começam.
    @roque_maior = 0
    @roque_menor = 0
    @roque_maior_pretas = 0
    @roque_menor_pretas = 0
    @ultima_jogada = ''
    @player1 = p1
    @player2 = p2

    @tabuleiro = [
      'TCBDRBCT',
      'PPPPPPPP',
      '        ',
      '        ',
      '        ',
      '        ',
      'pppppppp',
      'tcbdrbct'
    ]
#      @tabuleiro = [
#        'TCBDRBCT',
#        '    p   ',
#        '        ',
#        '        ',
#        '        ',
#        '        ',
#        '        ',
#        'tcbdrbct'
#      ]

     @arquivo = "#{File.dirname($0)}/#{codigo_jogo}.jogo"
     @ultima_jogada = Time.now.to_s
     salvar
  end

  def [](valor)
    return @tabuleiro[valor]
  end

  def salvar
    File.open(@arquivo + ".log", 'a') { |arq| arq.puts @ultima_jogada }

    File.open(@arquivo, 'w') { |arq| arq.puts self.to_yaml }
  end

  def fim_jogo(empate = false)
    @todas_jogadas = File.read(@arquivo + ".log").split("\n")
    if(empate)
      @todas_jogadas << "½-½"
    else
      if(@vez)
        @erros << "Brancas venceram!"
      else
        @erros << "Pretas venceram!"
      end
      todas_jogadas << @ultima_jogada
    end

    begin
      File.unlink(@arquivo + ".log")
      File.unlink(@arquivo)
    rescue
    end
  end

  def mover(movimento)
    @erros = []

    #Arruma os movimentos
    match = movimento.scan /([PTCBRD]?)([abcdefgh]?[12345678]?)[ -]?([x\:]?)([abcdefgh])([12345678])(\+{1,2}|#?)=?([TCBD]?)/
    if(match.empty?)
      if(movimento =~ /(0-0-0|O-O-O)/)
        return roque(:maior)
      elsif(movimento =~ /(0-0|O-O)/)
        return roque(:menor)
      elsif(movimento =~ /[0O]-1/)
        #Pretas ganham?
        if(@vez)
          @ultima_jogada = $~[0]
          fim_jogo
          return @ultima_jogada
        else
          @erros << "Jogada inválida."
        end
      elsif(movimento =~ /1-[0O]/)
        #Brancas ganham?
        if(@vez)
          @erros << "Jogada inválida."
        else
          @ultima_jogada = $~[0]
          fim_jogo
          return @ultima_jogada
        end
      else
        @erros << 'Não consegui entender seu movimento.'
      end
      return nil
    end

    ultima_jogada = $~[0]
    match = match[0]

    peca = match[0]
    peca = 'P' if peca == ''
    posicao = match[1]

    comeu = match[2] == ''? false: true
    x = match[3][0] - ?a
    y = match[4][0] - ?1
    check = match[5] == ''? false: true
    checkmate = match[5] == '++' or match[5] == '#'? true: false

    promocao = match[6]

    @en_passant = nil
    x1, y1 = qual_peca(peca, x, y, posicao, comeu, check)
    return nil if(x1.nil?)

    #Faz um "backup" do tabuleiro.
    tabuleiro = @tabuleiro.collect { |v| v.dup }

    @tabuleiro[y][x],  @tabuleiro[y1][x1] = @tabuleiro[y1][x1], ' '

    #Ver movimentação das torres ou do rei, para impedir o Roque.
    @roque_maior = @roque_menor = 1 if(peca == 'R' and @vez)
    @roque_maior_pretas = @roque_menor_pretas = 1 if(peca == 'R' and !@vez)

    #Ver promoção de peões:
    if(peca.upcase == 'P')
      if(y == 0 or y == 7)
        if(promocao =~ /[DTCB]/)
          promocao.downcase! if(@vez)
          @tabuleiro[y][x] = promocao
        else
          @erros << 'Você precisa informar a promoção.'
          @tabuleiro = tabuleiro
          return nil
        end
      end
    elsif(promocao != '' and !promocao.nil?)
      @tabuleiro = tabuleiro
      @erros << 'Nenhum peão está sendo promovido.'
      return nil
    end

    if(peca == 'T')
      case [x1, y1]
        when [0, 0]
          @roque_maior_pretas = 1
        when [0, 7]
          @roque_maior = 1
        when [7, 0]
          @roque_menor_pretas = 1
        when [7, 7]
          @roque_menor = 1
      end
    end

    if(@en_passant)
      @tabuleiro[@en_passant[1]][@en_passant[0]] = ' '
    end

    #Vê se na nova posição, seu rei fica em cheque:
    if(cheque?)
      @erros << "Com essa jogada, seu rei fica em cheque."
      @tabuleiro = tabuleiro
      return nil
    end

    #Vê se na nova posição, o rei do outro fica em cheque:
    if(cheque?(-1, -1, !@vez))
      unless(check)
        @erros << "Você deve informar ao outro que ele está em cheque."
        @tabuleiro = tabuleiro
        return nil
      else
        if(checkmate)
          @erros << "CHEQUE-MATE!"
        else
          @erros << "CHEQUE!"
        end
      end
    else
      if(check)
        @erros << "Você não está dando cheque."
        @tabuleiro = tabuleiro
        return nil
      end
    end

    @vez = !@vez
    @ultima_jogada = ultima_jogada
    return @ultima_jogada, x1, y1
  end

  def calcula_movimentos(peca, x, y, comeu = true)
    movimentos = []

    case peca.upcase
      when 'P':
        if(@vez)
          if(comeu)
             movimentos << [x-1, y+1] << [x+1, y+1]
          else
            movimentos << [x, y + 2] if(y == 4 and @tabuleiro[y+1][x].chr == ' ')
            movimentos << [x, y + 1]
          end
        else
          if(comeu)
             movimentos << [x-1, y-1] << [x+1, y-1]
          else
            movimentos << [x, y - 2] if(y == 3 and @tabuleiro[y-1][x].chr == ' ')
            movimentos << [x, y - 1]
          end
        end
      when 'T':
        (x+1).upto(7)   { |x1| break unless(@tabuleiro[y][x1].chr == ' ' or @tabuleiro[y][x1].chr == peca); movimentos << [x1, y] }
        (x-1).downto(0) { |x1| break unless(@tabuleiro[y][x1].chr == ' ' or @tabuleiro[y][x1].chr == peca); movimentos << [x1, y] }
        (y+1).upto(7)   { |y1| break unless(@tabuleiro[y1][x].chr == ' ' or @tabuleiro[y1][x].chr == peca); movimentos << [x, y1] }
        (y-1).downto(0) { |y1| break unless(@tabuleiro[y1][x].chr == ' ' or @tabuleiro[y1][x].chr == peca); movimentos << [x, y1] }

      when 'C':
        movimentos << [x+1, y+2] << [x+1, y-2] << [x+2, y+1] << [x+2, y-1] << [x-1, y+2] << [x-1, y-2] << [x-2, y+1] << [x-2, y-1]
      when 'B':
        1.upto(7) { |i| break if(y+i > 7 or x+i > 7); p = @tabuleiro[y+i][x+i].chr; break unless(p == ' ' or p == peca); movimentos << [x+i, y+i] }
        1.upto(7) { |i| break if(x+i > 7); p = @tabuleiro[y-i][x+i].chr; break unless(p == ' ' or p == peca); movimentos << [x+i, y-i] }
        1.upto(7) { |i| break if(y+i > 7); p = @tabuleiro[y+i][x-i].chr; break unless(p == ' ' or p == peca); movimentos << [x-i, y+i] }
        1.upto(7) { |i| p = @tabuleiro[y-i][x-i].chr; break unless(p == ' ' or p == peca); movimentos << [x-i, y-i] }
      when 'R':
        movimentos << [x+1, y+1] << [x+1, y-1] << [x-1, y+1] << [x-1, y-1]
        movimentos << [x, y+1] << [x, y-1] << [x+1, y] << [x-1, y]
      when 'D':
        1.upto(7) { |i| break if(y+i > 7 or x+i > 7); p = @tabuleiro[y+i][x+i].chr; break unless(p == ' ' or p == peca); movimentos << [x+i, y+i] }
        1.upto(7) { |i| break if(x+i > 7); p = @tabuleiro[y-i][x+i].chr; break unless(p == ' ' or p == peca); movimentos << [x+i, y-i] }
        1.upto(7) { |i| break if(y+i > 7); p = @tabuleiro[y+i][x-i].chr; break unless(p == ' ' or p == peca); movimentos << [x-i, y+i] }
        1.upto(7) { |i| p = @tabuleiro[y-i][x-i].chr; break unless(p == ' ' or p == peca); movimentos << [x-i, y-i] }
        (x+1).upto(7)   { |x1| break unless(@tabuleiro[y][x1].chr == ' ' or @tabuleiro[y][x1].chr == peca); movimentos << [x1, y] }
        (x-1).downto(0) { |x1| break unless(@tabuleiro[y][x1].chr == ' ' or @tabuleiro[y][x1].chr == peca); movimentos << [x1, y] }
        (y+1).upto(7)   { |y1| break unless(@tabuleiro[y1][x].chr == ' ' or @tabuleiro[y1][x].chr == peca); movimentos << [x, y1] }
        (y-1).downto(0) { |y1| break unless(@tabuleiro[y1][x].chr == ' ' or @tabuleiro[y1][x].chr == peca); movimentos << [x, y1] }

    end

    l = @tabuleiro[y][x].chr
    if(comeu and l == ' ')
      #Teste En Passant
      if(peca.upcase == 'P')
        y = @vez? 4: 5
        if(@ultima_jogada =~ /^P?[#{(x+?a).chr}#{y+1}]?#{(x+?a).chr}#{y}/)
          @en_passant = [x, y-1]
        end
      end

      unless(@en_passant)
        @erros << 'Jogada inválida - não comeu nenhuma peça.'
        return nil
      end
    elsif(!comeu and l != ' ')
      @erros << 'Jogada inválida - sobrepõe uma peça.'
      return nil
    elsif(comeu)
      #Vê se não sobrepôs nada seu.
      if(
          (@vez and (l.downcase == l)) or
          (!@vez and (l.upcase == l))
        )
        @erros << 'Jogada inválida - sobrepõe uma peça sua.'
        return nil
      end
    end

    return movimentos
  end

  def qual_peca(peca, x, y, posicao, comeu, check)
    peca.downcase! if(@vez)

    #FIXME: Falta o TAKE
    movimentos = calcula_movimentos(peca, x, y, comeu)
    return if(movimentos.nil?)

    pecas = []
    movimentos.delete_if { |x| x[0] > 7 or x[0] < 0 or x[1] > 7 or x[1] < 0 }
    movimentos.each do |dupla|
      x = dupla[0]
      y = dupla[1]

      if(@tabuleiro[y][x].chr == peca)
        pecas << [ @tabuleiro[y][x].chr, x, y ]
      end
    end

    case pecas.length
      when 0:
        erros << 'Movimento inválido.'
      when 1:
        return pecas[0][1], pecas[0][2]
      else
        posicao = posicao.scan(/^([abcdefgh]?)(\d?)$/).flatten

        pecas.delete_if { |p| p[1] != posicao[0][0] - ?a } unless(posicao[0] == '')
        pecas.delete_if { |p| p[2] != posicao[1][0] - ?1 } unless(posicao[1] == '')

        case(pecas.length)
          when 0:
            erros << "Movimento inválido."
          when 1:
            return pecas[0][1], pecas[0][2]
        end

        erros << 'Movimento ambíguo.'
    end

    return nil
  end

  def cheque?(x=-1, y=-1, lado = @vez)
    if(x == y and x == -1)
      #Procura o Rei.
      rei = 'R'
      rei = 'r' if(lado)

      @tabuleiro.each_with_index do |v, i|
        x = v =~ /#{rei}/
        if(x)
          y = i
          break
        end
      end

      unless(x)
        @erros << 'O rei não foi encontrado. O jogo já acabou?'
        if(lado)
          @vitoria = "Pretas"
        else
          @vitoria = "Brancas"
        end
        return false
      end
    end

    #Procura a peça do lado CONTRÁRIO!
    peao = 'p'
    torre = 't'
    cavalo = 'c'
    bispo = 'b'
    rei = 'r'
    rainha = 'd'
    if(lado)
      peao.upcase!
      torre.upcase!
      cavalo.upcase!
      bispo.upcase!
      rei.upcase!
      rainha.upcase!
    end

    movimentos = []

    #Movimentos do peão:
    if(lado) then movimentos = [ [x-1, y-1], [x+1, y-1] ] else movimentos = [ [x-1, y+1], [x+1, y+1] ] end
#     tem = movimentos.inject(false) { |t, (x1, y1)| if(x1 > 7 or x1 < 0 or y1 > 7 or y1 < 0) then false else t or (@tabuleiro[y1][x1] == peao) end }
    movimentos.each { |(x1, y1)| unless(x1 > 7 or x1 < 0 or y1 > 7 or y1 < 0) then return true if @tabuleiro[y1][x1].chr == peao end }

    #Torre ou Rainha:
    (x+1).upto(7)   { |x1| break unless(@tabuleiro[y][x1].chr == ' ' or @tabuleiro[y][x1].chr == torre or @tabuleiro[y][x1].chr == rainha); movimentos << [x1, y] }
    (x-1).downto(0) { |x1| break unless(@tabuleiro[y][x1].chr == ' ' or @tabuleiro[y][x1].chr == torre or @tabuleiro[y][x1].chr == rainha); movimentos << [x1, y] }
    (y+1).upto(7)   { |y1| break unless(@tabuleiro[y1][x].chr == ' ' or @tabuleiro[y1][x].chr == torre or @tabuleiro[y1][x].chr == rainha); movimentos << [x, y1] }
    (y-1).downto(0) { |y1| break unless(@tabuleiro[y1][x].chr == ' ' or @tabuleiro[y1][x].chr == torre or @tabuleiro[y1][x].chr == rainha); movimentos << [x, y1] }
    movimentos.each { |(x1, y1)| unless(x1 > 7 or x1 < 0 or y1 > 7 or y1 < 0) then return true if @tabuleiro[y1][x1].chr == torre or @tabuleiro[y1][x1].chr == rainha end }

    #Cavalo:
    movimentos << [x+1, y+2] << [x+1, y-2] << [x+2, y+1] << [x+2, y-1] << [x-1, y+2] << [x-1, y-2] << [x-2, y+1] << [x-2, y-1]
    movimentos.each { |(x1, y1)| unless(x1 > 7 or x1 < 0 or y1 > 7 or y1 < 0) then return true if @tabuleiro[y1][x1].chr == cavalo end }

    #Bispo ou Rainha:
    1.upto(7) { |i| break if(y+i > 7 or x+i > 7); p = @tabuleiro[y+i][x+i].chr; break unless(p == ' ' or p == bispo or p == rainha); movimentos << [x+i, y+i] }
    1.upto(7) { |i| break if(x+i > 7); p = @tabuleiro[y-i][x+i].chr;            break unless(p == ' ' or p == bispo or p == rainha); movimentos << [x+i, y-i] }
    1.upto(7) { |i| break if(y+i > 7); p = @tabuleiro[y+i][x-i].chr;            break unless(p == ' ' or p == bispo or p == rainha); movimentos << [x-i, y+i] }
    1.upto(7) { |i| p = @tabuleiro[y-i][x-i].chr;                               break unless(p == ' ' or p == bispo or p == rainha); movimentos << [x-i, y-i] }

    puts "\n\n\nSearching..."
    movimentos.each { |(x1, y1)| unless(x1 > 7 or x1 < 0 or y1 > 7 or y1 < 0) then return true if @tabuleiro[y1][x1].chr == bispo or @tabuleiro[y1][x1].chr == rainha end }

    #Rei:
    movimentos << [x+1, y+1] << [x+1, y-1] << [x-1, y+1] << [x-1, y-1]
    movimentos << [x, y+1] << [x, y-1] << [x+1, y] << [x-1, y]
    movimentos.each { |(x1, y1)| unless(x1 > 7 or x1 < 0 or y1 > 7 or y1 < 0) then return true if @tabuleiro[y1][x1].chr == rei end }

    return false
  end

  def roque(arg)
    p [@roque_maior, @roque_menor, @roque_maior_pretas, @roque_menor_pretas]
    y = @vez? 7: 0

    if(arg == :maior)
      if( (@roque_maior == 1 and @vez == 1) or (@roque_maior_pretas == 1 and @vez == 0))
        @erros << "Você não pode dar o roque maior."
        return
      end


      unless(@tabuleiro[y][2..3] == '  ')
        @erros << "Há uma peça no caminho."
        return
      end

      if(cheque?(4, y) or cheque?(3, y) or cheque?(2, y))
        @erros << "Seu rei está ou fica em cheque."
        return
      end


      @tabuleiro[y][2], @tabuleiro[y][3] = @tabuleiro[y][4], @tabuleiro[y][0]
      @tabuleiro[y][4], @tabuleiro[y][0] = ' ', ' '

      @roque_maior = @roque_menor = 1 if(@vez)
      @roque_maior_pretas = @roque_maior_pretas = 1 if(!@vez)

      @vez = !@vez
      return '0-0-0'
    else
      if( (@roque_menor == 1 and @vez) or (@roque_menor_pretas == 1 and !@vez))
        @erros << "Você não pode dar o roque menor."
        return
      end

      unless(@tabuleiro[y][5..6] == '  ')
        @erros << "Há uma peça no caminho."
        return
      end

      if(cheque?(4, y) or cheque?(5, y) or cheque?(6, y))
        @erros << "Seu rei está ou fica em cheque."
        return
      end

      @tabuleiro[y][5], @tabuleiro[y][6] = @tabuleiro[y][7], @tabuleiro[y][4]
      @tabuleiro[y][4], @tabuleiro[y][7] = ' ', ' '

      @roque_maior = @roque_menor = 1 if(@vez)
      @roque_maior_pretas = @roque_maior_pretas = 1 if(!@vez)

      @vez = !@vez
      return '0-0'
    end
  end
end
