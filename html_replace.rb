class String

  #Acaba com todos os códigos HTML do programa. Se a opção "formatacao" for verdadeira, mantém
  #a formatação substituindo por *negrito*, /itálico/ e _sublinhado_
  def strip_html(formatacao = false)
    return gsub(/<\/?[^>]*>/) do |tag|
      if(formatacao)
        #Deixa só o nome da tag:
        tag = tag.match(/(?<=\<)[^\s>]+/).to_s
        case tag
          when /br.*/
            "\n"
          when '/p'
            "\n"
          when 'b', '/b', 'strong', '/strong'
            '*'
          when 'i', '/i'
            '/'
          when 'u', '/u'
            '_'
        end
      end
    end
  end

  def decode_entities
    return gsub(/\&.*?;/) do |ent|
      case ent
        when '&quot;'
          '"'
        when '&amp;'
          '&'
        when '&apos;'
          '\''
        when '&lt;'
          '<'
        when '&gt;'
          '>'
        when '&nbsp;'
          ''
        when '&iexcl;'
          '¡'
        when '&cent;'
          '¢'
        when '&pound;'
          '£'
        when '&curren;'
          '¤'
        when '&yen;'
          '¥'
        when '&brvbar;'
          '¦'
        when '&sect;'
          '§'
        when '&uml;'
          '¨'
        when '&copy;'
          '©'
        when '&ordf;'
          'ª'
        when '&laquo;'
          '«'
        when '&not;'
          '¬'
        when '&shy;'
          ''
        when '&reg;'
          '®'
        when '&macr;'
          '¯'
        when '&deg;'
          '°'
        when '&plusmn;'
          '±'
        when '&sup2;'
          '²'
        when '&sup3;'
          '³'
        when '&acute;'
          '´'
        when '&micro;'
          'µ'
        when '&para;'
          '¶'
        when '&middot;'
          '·'
        when '&cedil;'
          '¸'
        when '&sup1;'
          '¹'
        when '&ordm;'
          'º'
        when '&raquo;'
          '»'
        when '&frac14;'
          '¼'
        when '&frac12;'
          '½'
        when '&frac34;'
          '¾'
        when '&iquest;'
          '¿'
        when '&Agrave;'
          'À'
        when '&Aacute;'
          'Á'
        when '&Acirc;'
          'Â'
        when '&Atilde;'
          'Ã'
        when '&Auml;'
          'Ä'
        when '&Aring;'
          'Å'
        when '&AElig;'
          'Æ'
        when '&Ccedil;'
          'Ç'
        when '&Egrave;'
          'È'
        when '&Eacute;'
          'É'
        when '&Ecirc;'
          'Ê'
        when '&Euml;'
          'Ë'
        when '&Igrave;'
          'Ì'
        when '&Iacute;'
          'Í'
        when '&Icirc;'
          'Î'
        when '&Iuml;'
          'Ï'
        when '&ETH;'
          'Ð'
        when '&Ntilde;'
          'Ñ'
        when '&Ograve;'
          'Ò'
        when '&Oacute;'
          'Ó'
        when '&Ocirc;'
          'Ô'
        when '&Otilde;'
          'Õ'
        when '&Ouml;'
          'Ö'
        when '&times;'
          '×'
        when '&Oslash;'
          'Ø'
        when '&Ugrave;'
          'Ù'
        when '&Uacute;'
          'Ú'
        when '&Ucirc;'
          'Û'
        when '&Uuml;'
          'Ü'
        when '&Yacute;'
          'Ý'
        when '&THORN;'
          'Þ'
        when '&szlig;'
          'ß'
        when '&agrave;'
          'à'
        when '&aacute;'
          'á'
        when '&acirc;'
          'â'
        when '&atilde;'
          'ã'
        when '&auml;'
          'ä'
        when '&aring;'
          'å'
        when '&aelig;'
          'æ'
        when '&ccedil;'
          'ç'
        when '&egrave;'
          'è'
        when '&eacute;'
          'é'
        when '&ecirc;'
          'ê'
        when '&euml;'
          'ë'
        when '&igrave;'
          'ì'
        when '&iacute;'
          'í'
        when '&icirc;'
          'î'
        when '&iuml;'
          'ï'
        when '&eth;'
          'ð'
        when '&ntilde;'
          'ñ'
        when '&ograve;'
          'ò'
        when '&oacute;'
          'ó'
        when '&ocirc;'
          'ô'
        when '&otilde;'
          'õ'
        when '&ouml;'
          'ö'
        when '&divide;'
          '÷'
        when '&oslash;'
          'ø'
        when '&ugrave;'
          'ù'
        when '&uacute;'
          'ú'
        when '&ucirc;'
          'û'
        when '&uuml;'
          'ü'
        when '&yacute;'
          'ý'
        when '&thorn;'
          'þ'
        when '&yuml;'
          'ÿ'
        when '&OElig;'
          'Œ'
        when '&oelig;'
          'œ'
        when '&Scaron;'
          'Š'
        when '&scaron;'
          'š'
        when '&Yuml;'
          'Ÿ'
        when '&fnof;'
          'ƒ'
        when '&circ;'
          'ˆ'
        when '&tilde;'
          '˜'
        when '&Alpha;'
          'Α'
        when '&Beta;'
          'Β'
        when '&Gamma;'
          'Γ'
        when '&Delta;'
          'Δ'
        when '&Epsilon;'
          'Ε'
        when '&Zeta;'
          'Ζ'
        when '&Eta;'
          'Η'
        when '&Theta;'
          'Θ'
        when '&Iota;'
          'Ι'
        when '&Kappa;'
          'Κ'
        when '&Lambda;'
          'Λ'
        when '&Mu;'
          'Μ'
        when '&Nu;'
          'Ν'
        when '&Xi;'
          'Ξ'
        when '&Omicron;'
          'Ο'
        when '&Pi;'
          'Π'
        when '&Rho;'
          'Ρ'
        when '&Sigma;'
          'Σ'
        when '&Tau;'
          'Τ'
        when '&Upsilon;'
          'Υ'
        when '&Phi;'
          'Φ'
        when '&Chi;'
          'Χ'
        when '&Psi;'
          'Ψ'
        when '&Omega;'
          'Ω'
        when '&alpha;'
          'α'
        when '&beta;'
          'β'
        when '&gamma;'
          'γ'
        when '&delta;'
          'δ'
        when '&epsilon;'
          'ε'
        when '&zeta;'
          'ζ'
        when '&eta;'
          'η'
        when '&theta;'
          'θ'
        when '&iota;'
          'ι'
        when '&kappa;'
          'κ'
        when '&lambda;'
          'λ'
        when '&mu;'
          'μ'
        when '&nu;'
          'ν'
        when '&xi;'
          'ξ'
        when '&omicron;'
          'ο'
        when '&pi;'
          'π'
        when '&rho;'
          'ρ'
        when '&sigmaf;'
          'ς'
        when '&sigma;'
          'σ'
        when '&tau;'
          'τ'
        when '&upsilon;'
          'υ'
        when '&phi;'
          'φ'
        when '&chi;'
          'χ'
        when '&psi;'
          'ψ'
        when '&omega;'
          'ω'
        when '&thetasym;'
          'ϑ'
        when '&upsih;'
          'ϒ'
        when '&piv;'
          'ϖ'
        when '&ensp;'
          ' '
        when '&emsp;'
          ' '
        when '&thinsp;'
          ' '
        when '&zwnj;'
          ''
        when '&zwj;'
          ''
        when '&lrm;'
          ''
        when '&rlm;'
          ''
        when '&ndash;'
          '–'
        when '&mdash;'
          '—'
        when '&lsquo;'
          '‘'
        when '&rsquo;'
          '’'
        when '&sbquo;'
          '‚'
        when '&ldquo;'
          '“'
        when '&rdquo;'
          '”'
        when '&bdquo;'
          '„'
        when '&dagger;'
          '†'
        when '&Dagger;'
          '‡'
        when '&bull;'
          '•'
        when '&hellip;'
          '…'
        when '&permil;'
          '‰'
        when '&prime;'
          '′'
        when '&Prime;'
          '″'
        when '&lsaquo;'
          '‹'
        when '&rsaquo;'
          '›'
        when '&oline;'
          '‾'
        when '&frasl;'
          '⁄'
        when '&euro;'
          '€'
        when '&image;'
          'ℑ'
        when '&weierp;'
          '℘'
        when '&real;'
          'ℜ'
        when '&trade;'
          '™'
        when '&alefsym;'
          'ℵ'
        when '&larr;'
          '←'
        when '&uarr;'
          '↑'
        when '&rarr;'
          '→'
        when '&darr;'
          '↓'
        when '&harr;'
          '↔'
        when '&crarr;'
          '↵'
        when '&lArr;'
          '⇐'
        when '&uArr;'
          '⇑'
        when '&rArr;'
          '⇒'
        when '&dArr;'
          '⇓'
        when '&hArr;'
          '⇔'
        when '&forall;'
          '∀'
        when '&part;'
          '∂'
        when '&exist;'
          '∃'
        when '&empty;'
          '∅'
        when '&nabla;'
          '∇'
        when '&isin;'
          '∈'
        when '&notin;'
          '∉'
        when '&ni;'
          '∋'
        when '&prod;'
          '∏'
        when '&sum;'
          '∑'
        when '&minus;'
          '−'
        when '&lowast;'
          '∗'
        when '&radic;'
          '√'
        when '&prop;'
          '∝'
        when '&infin;'
          '∞'
        when '&ang;'
          '∠'
        when '&and;'
          '∧'
        when '&or;'
          '∨'
        when '&cap;'
          '∩'
        when '&cup;'
          '∪'
        when '&int;'
          '∫'
        when '&there4;'
          '∴'
        when '&sim;'
          '∼'
        when '&cong;'
          '≅'
        when '&asymp;'
          '≈'
        when '&ne;'
          '≠'
        when '&equiv;'
          '≡'
        when '&le;'
          '≤'
        when '&ge;'
          '≥'
        when '&sub;'
          '⊂'
        when '&sup;'
          '⊃'
        when '&nsub;'
          '⊄'
        when '&sube;'
          '⊆'
        when '&supe;'
          '⊇'
        when '&oplus;'
          '⊕'
        when '&otimes;'
          '⊗'
        when '&perp;'
          '⊥'
        when '&sdot;'
          '⋅'
        when '&lceil;'
          '⌈'
        when '&rceil;'
          '⌉'
        when '&lfloor;'
          '⌊'
        when '&rfloor;'
          '⌋'
        when '&lang;'
          '〈'
        when '&rang;'
          '〉'
        when '&loz;'
          '◊'
        when '&spades;'
          '♠'
        when '&clubs;'
          '♣'
        when '&hearts;'
          '♥'
        when '&diams;'
          '♦'
      end
    end
  end
end