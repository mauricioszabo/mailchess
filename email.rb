#!/usr/bin/env ruby 

Dir.chdir File.expand_path(File.dirname(__FILE__))
require 'rubygems'
gem 'tmail'
require 'tmail'
require 'tela.rb'
require 'net/pop'
require 'net/smtp'
require 'html_replace.rb'
require 'tela.rb'

class Email
  def initialize
    @config = YAML::load_file 'config.yaml'
  end
  
  def fetch
    puts "Fetching..."
    pop = Net::POP.new @config["email"]["pop3"]
    pop.start @config["email"]["usuario"], @config["email"]["senha"]
    
    p pop.mails

    pop.mails.each do |m|
      mensagem = TMail::Mail.parse m.pop
      
      #email = E-Mail da pessoa que enviou a mensagem.
      email = ''
      #assunto = Assunto do e-mail.
      assunto = ''
      #mensagem = No fim de tudo, deve ser uma mensagem sem formatação nenhuma.
    
      if(mensagem.from)
        email = mensagem.from_addrs[0].address
      else
        email = mensagem.header["return-path"].to_s
      end
      assunto = mensagem.subject if mensagem.subject
    
      msg = mensagem
      while(msg.multipart?)
        msg.parts.each do |parte|
          msg = parte if(parte.main_type == 'multipart')
          if(parte.content_type == "text/plain")
            msg = parte
            break
          elsif(parte.content_type == "text/html")
            msg = parte
          end
        end
      end
    
      mensagem = msg.body
      if(msg.content_type == "text/html")
        mensagem = mensagem.strip_html
        mensagem = mensagem.decode_entities
      end

      mensagem.gsub! /\>.*/, ''
      mensagem.strip!
    
      jogada = mensagem.match(/\s*jogada:\s*(.*)/i)
      if(jogada and assunto =~ /jogo\s*(\d+)/i)
        jogada = jogada.values_at(1)[0]
        joga(jogada, assunto, email, mensagem)
      elsif assunto =~ /novo jogo/i
        novo_jogo(mensagem, email)
      else
        unless(mensagem =~ /mail.*daemon/i)
          msg = "Erro em seu e-mail, seu comando ou jogada não foi entendido.\n\nLembre-se que para a jogada ser " +
            "considerada válida, o assunto da mensagem deve ser válido, e o e-mail deve conter uma das seguintes:\n\n" +
            "Jogada: <jogada_valida>\nou\n" + 
            "Jogada: empate?\nou\n\n" + 
            "Assunto=Novo Jogo\nCorpo da Mensagem=Pretas: <email_das_pretas> e Brancas=<email_das_brancas>\n\n" +
            "Abaixo, uma cópia de sua mensagem:\n\n"
            
          msg += mensagem.gsub(/(.*)i\n?/, "> \\1\n")
          send_mail(email, cria_erro(email, msg, 'Erro em seu e-mail'))
        end
      end
      
      m.delete
    end

    pop.finish
  end
 
  def daemon
    Signal.trap('HUP', 'IGNORE')

    while(true)
      fetch
      sleep 60
    end
  end

  def joga(jogada, assunto, email, mensagem)
    numero_jogo = assunto.scan(/jogo\s*(\d+)/i)
    numero_jogo = numero_jogo[0][0].to_i
    
    tela = Tela.new(numero_jogo)
    
    unless(tela.vez_correta?(email))
      send_mail(email, cria_erro(email, "Não é a sua vez!", assunto))
      return
    end
    
    imagem, ret = tela.mover(jogada)
    
    if(ret =~ /([0O]-1|1-[0O])/)
      #Fim de jogo
      manda_mensagem("Fim de jogo. O log da partida é: <br/><br/>#{tela.jogadas.join("<br/>")}.", "Jogo #{numero_jogo}", imagem, tela, true)
    elsif(ret.nil?)
      #Jogada inválida.
      manda_mensagem("Jogada (#{jogada}) inválida.", "Jogo #{numero_jogo}", imagem, tela)
    else
      msg = "Seu adversário (#{email}) fez o movimento: #{ret}<br /><br  />"+
        "Abaixo, uma cópia da mensagem que seu adversário enviou:<br/><br/><pre>"
      msg += mensagem.gsub(/(.*)\n?/, "> \\1\n") + "</pre><br />#{tela.cor_vez} jogam:"

      manda_mensagem(msg, "Jogo #{numero_jogo}", imagem, tela)
    end
  end
  
  def novo_jogo(mensagem, myself)
    p mensagem

    pretas = mensagem.scan /pretas:\s*(.*)/i
    brancas = mensagem.scan /brancas:\s*(.*)/i

    pretas = pretas.to_s
    brancas = brancas.to_s
    
    if(pretas.empty? and brancas.empty?)
      msg = "Erro em seu e-mail, você deve informar pelo menos um dos e-mails (brancas ou pretas)\n\n" +
        "Abaixo, uma cópia de sua mensagem:\n\n"
      msg += mensagem.gsub(/(.*)\n?/, "> \\1\n")
      send_mail(myself, cria_erro(myself, msg, 'Erro em seu e-mail'))
    else
      pretas = myself if pretas.empty?
      brancas = myself if brancas.empty?
      
      tela = Tela.new(0, brancas, pretas)
      jogo = tela.codigo_jogo
      
      msg = "Um novo jogo foi criado! O código do jogo é #{jogo}. Aguarde enquanto #{brancas} joga..."
      send_mail(pretas, cria_erro(pretas, msg, 'Novo jogo criado!'))
      
      msg = "Um novo jogo foi criado! O código do jogo é #{jogo}. Sua jogada? Lembre-se, informe a jogada com<br />"+
        "Jogada: &lt;sua_jogada&gt;"
      manda_mensagem(msg, "Jogo #{jogo}", tela.desenha, tela)
    end
  end
  
  def manda_mensagem(mensagem, assunto, imagem, tela, dois=false)
    msg = TMail::Mail.new
    part1 = TMail::Mail.new
    att = TMail::Mail.new
    imagem = imagem.to_blob
    
    part1.set_content_type 'text', 'html', {'charset' => 'UTF8' }
    part1.body = "#{mensagem}<br /><br /><img src=\"cid:tabuleiro\">"
    
    att['content-yd'] = '<tabuleiro>'
    att.set_content_type 'image','jpg', { 'name' => 'imagem.jpg' }
    att.set_content_disposition 'inline'
    att.set_content_disposition('inline', "filename" => '"imagem.jpg"')
    att.content_transfer_encoding = 'base64'
    att.body = TMail::Base64.folding_encode(imagem)
    
    msg.parts << part1
    msg.parts << att
    if(dois)
      msg.to = tela.emails
    else
      msg.to = tela.email
    end
    msg.from = @config['email']['email']
    msg.subject = assunto
    msg.date = Time.now
    msg.mime_version = '1.0'
    msg.content_type = 'multipart/related'
    msg = msg.encoded.gsub('Content-Yd', 'Content-ID')

    if(dois)
      send_mail(tela.emails[0], msg)
      send_mail(tela.emails[1], msg)
    else
      send_mail(tela.email, msg)
    end
  end
  
  def cria_erro(to, mensagem, assunto)
    m = TMail::Mail.new
    m.to = 'mauricio.szabo@gmail.com'
    m.from = @config['email']['email']
    m.subject = assunto
    m.date = Time.now
    m.mime_version = '1.0'
    m.set_content_type 'text', 'plain', { 'charset' => 'utf8' }
    m.body = mensagem
    
    return m.encoded
  end
  
  def send_mail(to, mensagem)
    puts "Sending mail to: #{to}"
    Net::SMTP.start(@config['email']['smtp'], @config['email']['smtp_port'], 'localhost', 
                    @config['email']['usuario'], @config['email']['senha'], :login) do |smtp|
      smtp.send_message mensagem, @config['email']['email'], to
    end
  end
end

if(__FILE__ == $0)
  if(ARGV.include? "-d")
    pid = fork do 
      Process.setsid
      STDIN.reopen "/dev/null"
      STDOUT.reopen "/var/log/mailchess/mailchess.log", "a"
      STDERR.reopen STDOUT
      trap("TERM") do 
        begin
          File.unlink '/var/run/mailchess/mailchess.pid'
        rescue
        end

        exit 0
      end
      Email.new.daemon 
      exit 0
    end

    File.open("/var/run/mailchess/mailchess.pid", 'w') { |f| f.print pid }
  else
    Email.new.daemon
  end
end
