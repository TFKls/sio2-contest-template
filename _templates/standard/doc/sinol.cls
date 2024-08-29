%
% Makrodefinicje systemu SINOL
%
% \history{1.0}{Grzegorz Jakacki}{98/11/15}
% \history{1.1}{Grzegorz Jakacki}{99/11/28}
% \history{1.2}{Tomasz Walen}{00/09/14}
% \history{1.2.1}{Tomasz Walen --- nazwy plikow pisane sa malymi lit.}{01/03/23}
% \history{1.3}{Tomasz Waleń --- lepsza obsluga obrazkow, przykladow, wiele trybów komentowania dokumentów }{01/04/02}
% \history{1.3.1}{Tomasz Waleń --- drobne zmiany, dodanie sinolLang, logo BOI}
% \history{1.3.2}{Tomasz Waleń --- dodanie trybu we/wyj}
% \history{1.4}{Marcin Kubica --- Dodanie ilości potrzebnej pamięci \RAM. Dodanie rysunków do całych przykładów \exampleimg.}
% \history{1.4.1}{Jakub Pawlewicz --- nieładowanie klas babel i inputenc w wersji angielskiej}
% \history{1.5}{Marcin Kubica --- dostosowanie do potrzeb konkursów
% międzynarodowych (CEOI)}
% \history{1.6}{Marcin Kubica --- dostosowanie do potrzeb IOI'2005:
%   - opcja \iomode{otputonly}
%   - opcja \iomode{interactive}
%   - \pagestyle{fancy} działa tak, jak na IOI
%   - polecenie \Country
%   - \includegraphics zamiast \epsffile}
% \history{1.7}{Adam Iwanicki --- zmiana w tresci przykladowej input na
%          verbatiminput, bo poprzednie polecenie nie zachowywalo jednak
%          enterow}
% \history{1.7.1}{Marcin Kubica --- poprawka w \@exampleputtogetherv
%          dostosowująca do verbatiminput.
% \history(1.7.2}{Marcin Kubica --- zwiekszenie miejsca na tytul zadania,
%          kosztem miejsca na nazwe kraju}
% \history(1.8}{Szymon Acedanski --- zwiekszenie miejsca na tekst,
%          zdecydowane zmniejszenie marginesow strony}
% \history{1.9}{Tomasz Idziaszek --- rozne zmiany.}
% \history{1.9.1}{Tomasz Idziaszek --- drobne zmiany.}
% \history{1.9.2}{Marcin Kubica --- drobne zmiany + opcja utf8.}
% \history{1.9.3}{Jakub Radoszewski --- nowe logo OI, dodanie lmodern
%          usuwa bledy dvipdfa, frenchspacing - pojedyncze odstepy po kropce.}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\NeedsTeXFormat{LaTeX2e}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\sinolVersion{1.9.3}
\ProvidesClass{sinol}[1998/09/14 System Informatyczny Olimpiady \sinolVersion]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage[T1]{fontenc}
\usepackage{lmodern}
\RequirePackage{epsf}
\RequirePackage{graphicx}
\RequirePackage{ifpdf}
\RequirePackage{fancyhdr}
\RequirePackage[latin2,utf8]{inputenc}
\RequirePackage{verbatim}

% LANGUAGES
\input{languages/sinol-lang.cls}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Opcje dotyczace kodowania
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\sinolInputEncoding{latin2} %% Default encoding
\DeclareOption{utf8}{%
  \def\sinolInputEncoding{utf8}
}
\frenchspacing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rozmiar papieru
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zmienne logiczne
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newif\ifsinolshortages \sinolshortagesfalse % niedoprecyzowania
\newif\ifsinolerrors  \sinolerrorsfalse % bledy
\newif\ifmetric  \metrictrue  % czy drukowac metryke
\newif\ifzawodnik \zawodnikfalse  % czy wersja dla zawodnika
\newif\ifsignaturedefed \signaturedefedfalse % czy zdefiniowano sygnature
\newif\ifdatedefed \datedefedfalse  % czy podano date
\newif\ifetapdefed \etapdefedfalse  % czy podano etap
\newif\ifkonkursdefed \konkursdefedfalse  % czy podano konkurs
\newif\ifdaydefed \daydefedfalse  % czy podano dzien
\newif\ifRAMdefed \RAMdefedfalse  % czy podano dostępną pamięć
\newif\iftimedefed \timedefedfalse % czy podano czas działania
\newif\ifDocVersiondefed % czy zdefiniowano wersję dokumentu
\DocVersiondefedfalse    % (domyślnie nie)
\newif\ifCountrydefed \Countrydefedfalse % Czy zdefiniowano kraj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% \?{<tekst>} --- niedoprecyzowanie
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand\?[1]{%
% w zaleznosci od wybranego stylu, komentarze moga sie pojawiac
% tuz po niejasnosci, jako przypis lub na koncu
  \def\@tempf{footnote}\def\@tempa{appendix}\def\@tempm{margin}%%
  \edef\@tempcstyle{\cstyle}%
  \if@minipage\def\@tempcstyle{inline}\fi%
  \ifx\@tempcstyle\@tempf%
%%%% uwagi jako przypisy
    \footnote{#1}%
  \else%
    \ifx\@tempcstyle\@tempm%
%%%% uwagi na marginiesie
       \stepcounter{sinolCommentNumber}%
       $^\thesinolCommentNumber$%
       \marginpar{\raggedright \footnotesize $^\thesinolCommentNumber$#1}%
    \else%
       \ifx\@tempcstyle\@tempa%
%%%% tradycyjna uwaga bezpośrednio w tekście
         \addComment{#1}%
       \else%
         {
         \tt
         [[[#1]]]
         }
       \fi%
    \fi%
  \fi%
  \global\sinolshortagestrue%
}
% komentarze do treści zadań
%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\cstyle{inline}
\newcounter{sinolCommentNumber}
\global\def\comments{}
\newcommand\commentStyle[1]{
  \edef\cstyle{#1}%
}
%
\newcommand\addComment[1]{%
\stepcounter{sinolCommentNumber}%
$^\thesinolCommentNumber$%
\edef\comments{\comments\par $^\thesinolCommentNumber$ #1}
}
%
\newcommand\showComments{
  \def\@empty{}
  \ifx\comments\@empty\else
    %\section{\sinolSNameUwagi}
    \comments
  \fi
}
% uwaga do treści zadania
\renewcommand\comment[2]{%
  {\it \underline{#1}}
  \?{#2}
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rozwijajace \uppercase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\ucase#1{\expandafter\uppercase\expandafter{#1}}
\def\lcase#1{\expandafter\lowercase\expandafter{#1}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% logo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\LOGO{%
  \leavevmode
  \hbox{%
    \vbox to 0pt{%
      \vss
      \hbox{%
        % \textbf{\sinolLangShow{}}%
        \includegraphics[height=2cm]{\sinolContestLogo}%
      }%
    }%
  }%
}%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \ifundef{<makro>}{<jesli tak>}{<jesli nie>}
% --- wykonuje jeden z blokow, w zaleznosci od tego,
%     czy makro jest zdefiniowane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\ifundef#1#2#3{
  \expandafter
  \ifx\csname #1\endcsname\relax
    #2
  \else
    #3
  \fi
}
\def\ifeq#1#2#3{%
  \edef\@tempeqa{#1}%
  \edef\@tempeqb{#2}%
  \ifx\@tempeqa\@tempeqb
    #3
  \fi
}
\def\ifneq#1#2#3{%
  \edef\@tempeqa{#1}%
  \edef\@tempeqb{#2}%
  \ifx\@tempeqa\@tempeqb\else
    #3
  \fi
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% numery plikow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\chardef\inffile=15 % plik wejsciowy (np. testy)
\chardef\errfile=14 % plik wyjsciowy
\chardef\tmpfile=13 % plik tymczasowy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dane do metryki
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\sinolHistory{}
\def\sinolSignature{}
\def\sinolDocVersion{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \concludedecls --- uruchamiane po przeczytaniu deklaracji
% \concludetext --- uruchamiane po przeczytaniu tekstu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\concludedecls}{}
\newcommand{\concludetext}{}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% numer rozdzialu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcount\sinolSectionNumber \sinolSectionNumber=0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Footnote-ki indeksowane symbolami, a nie liczbami.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\def\thefootnote{\fnsymbol{footnote}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \infoutput{<tekst>} --- wyprowadza do pliku informacyjnego
% \erroutput{<tekst>} --- wyprowadza do pliku z bledami
% \erroutputWrongSection{<jest>}{<winno byc>} --- wyprowadza
%   informacje o blednej nazwie rodzialu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\infoutput}[1]{%
  \immediate\write\inffile{#1}
}

\newcommand{\erroutput}[1]{%
  \immediate\write\errfile{#1}
  \global\sinolerrorstrue
}

\newcommand{\erroutputWrongSection}[2]{%
  \erroutput{bledna nazwa lub lokalizacja rozdzialu '#1', spodziewane '#2'}%
}
%%
% obsluga obrazkow (TW, 2001.04.02)
%
%
\newlength{\imgwidth}
% podpis pod/nad obrazkiem
\newcommand\imgcaption[1]{%
\def\capwidth{\textwidth}%
\addtolength\capwidth{-1cm}%
\centerline{\begin{minipage}{\capwidth}\footnotesize #1\end{minipage}}%
}
%
% rysunek #1-plik, #2-podpis, #3-gdzie podpis (t-na gorze, b-na dole)
\newcommand\img[3]{%
\def\tmparg{#3}
\def\tmpb{b}
\setlength\imgwidth{\textwidth}%
\addtolength\imgwidth{-2cm}%
\begin{center}%
\begin{minipage}{\imgwidth}%
\ifx\tmparg\tmpb
  $$\includegraphics{#1}$$%
  \hrule%
  \smallskip%
  \imgcaption{#2}%
\else
  \imgcaption{#2}%
  \smallskip%
  \hrule%
  \smallskip%
  $$\includegraphics{#1}$$%
\fi
\end{minipage}\end{center}}
%
% rysunek z podpisem na gorze
\newcommand\timg[2]{\img{#1}{#2}{t}}
% rysunek z podpisem na dole
\newcommand\bimg[2]{\img{#1}{#2}{b}}
\newcommand\plainimg[1]{$\includegraphics{#1}$}
% tryb dwukolumnowy (kolumny -- #1 i #2)
\newcommand\twocol[2]{%
\begin{center}%
\begin{minipage}[t]{0.5\textwidth}%
\vspace{0pt}%
{#1}%
\end{minipage}\hfill%
\begin{minipage}[t]{0.5\textwidth}%
\vspace{0pt}%
{#2}%
\end{minipage}%
\end{center}}
%
%
% Rozpoznawanie rysunków pochodzących z MetaPosta
\ifpdf
%    \input supp-pdf.tex
%    \input supp-mis.tex

    \DeclareGraphicsRule{.1}{mps}{*}{}
    \DeclareGraphicsRule{.2}{mps}{*}{}
    \DeclareGraphicsRule{.3}{mps}{*}{}
    \DeclareGraphicsRule{.4}{mps}{*}{}
    \DeclareGraphicsRule{.5}{mps}{*}{}
    \DeclareGraphicsRule{.6}{mps}{*}{}
    \DeclareGraphicsRule{.7}{mps}{*}{}
    \DeclareGraphicsRule{.8}{mps}{*}{}
    \DeclareGraphicsRule{.9}{mps}{*}{}
\fi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
\let\oldpagestyle\pagestyle
\def\sinolPageStyle{fancy}
\renewcommand{\pagestyle}[1]{%
  \gdef\sinolPageStyle{#1}%
  \oldpagestyle{#1}
}

\newcommand{\signature}[1]{%
  \def\sinolSignature{#1}%
  \infoutput{[signature][#1]}%
  \global\signaturedefedtrue
}

\newcommand{\history}[3]{%
  \edef\sinolHistory{\noindent $\bullet$\ v.\,#3: #1, #2\par\sinolHistory}%
  \infoutput{[history][#1][#2][#3]}%
  \gdef\sinolDocVersion{#3}%
  \DocVersiondefedtrue%
}

\newcommand{\uses}[1]{%
  \infoutput{[uses][#1]}%
}

\renewcommand{\date}[1]{%
  \def\sinolDate{#1}%
  \global\datedefedtrue
}

\newcommand{\etap}[1]{%
  \def\sinolEtap{#1}%
  \global\etapdefedtrue
}

\newcommand{\konkurs}[1]{%
  \def\sinolKonkurs{#1}%
  \global\konkursdefedtrue
}

\renewcommand{\day}[1]{%
  \def\sinolDay{#1}%
  \global\daydefedtrue
}

\newcommand{\RAM}[1]{
  \def\sinolRAM{#1}%
  \global\RAMdefedtrue
}

\newcommand{\Time}[1]{
  \def\sinolTime{#1\,s}%
  \global\timedefedtrue
}

\newcommand{\Country}[1]{
  \def\sinolCountry{#1}%
  \global\Countrydefedtrue
}

\newcommand{\infile}{{\ttfamily XXX.IN}}
\newcommand{\outfile}{{\ttfamily XXX.IN}}

\def\sinolContestLogo{logo}

\def\sinolSolNameC{.c}
\def\sinolSolNameCPP{.cpp}
\def\sinolSolNamePAS{.pas}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


\newcommand{\iffileexists}[3]{%
  \immediate\openin\tmpfile #1\par
  \ifeof\tmpfile
    \immediate\closein\tmpfile
    #3
  \else
    \immediate\closein\tmpfile
    #2
  \fi
}

\AtBeginDocument{%
  \immediate\openout\inffile \jobname.inf
  \immediate\openout\errfile \jobname.err
}

\AtEndDocument{%
  \ifsinolerrors
    \immediate\write16{SINOL: znaleziono bledy (zob. \jobname.err) !}
  \fi
  \ifsinolshortages
    \immediate\write16{SINOL: znaleziono niedoprecyzowania (wystepuje '[[[...]]]')}
  \fi
}

\DeclareOption{pom}{%
  \def\sinolcat{pom}
  \def\xsinolcat{\sinolTitlePomysl}
  \newcommand{\source}[1]{%
    \def\sinolSource{#1}%
    \infoutput{[source][#1]}%
  }
  \renewcommand{\author}[1]{%
    \def\sinolAuthor{#1}%
    \infoutput{[author][#1]}%
  }
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }
  \newcommand{\makemetric}{%
    {
      \footnotesize
      {\noindent\bfseries \sinolSourceText:}
        \ifundef{sinolSource}{\?{brak}}{\sinolSource}\par
      {\noindent\bfseries \sinolSNameHistory:}\par
      \sinolHistory
    }
  }
  \renewcommand{\concludedecls}{%
    \edef\sinolIdSignature{\sinolSignature}%
  }%
}

\DeclareOption{spe}{%
  \def\sinolcat{spe}
  \def\xsinolcat{\sinolTitleSpecyfikacja}
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }
  \newcommand{\id}[1]{%
    \edef\ID{#1}%
    \infoutput{[id][#1]}%
  }
  \newcommand{\makemetric}{%
    {
      \footnotesize
      {\noindent\bfseries \sinolSNameHistory:}\par
      \sinolHistory
    }
  }
  \renewcommand{\concludedecls}{%
    \edef\sinolIdSignature{\sinolSignature}%
  }%
}

\newcommand\includefile[1]{
\vspace{-0.7em}
\verbatiminput{#1}
}


\def\sinolCatNameZad{zad}
\DeclareOption{zad}{%
  \def\sinolcat{zad}
  \def\xsinolcat{\sinolTitleTask}
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }
  \newcommand{\id}[1]{%
    \edef\ID{#1}%
    \infoutput{[id][#1]}%
  }

  \newcommand{\exampleinputimg}[1]{%
    \edef\exampleInImg{#1}%
  }

  \newcommand{\exampleoutputimg}[1]{%
    \edef\exampleOutImg{#1}%
  }

  \newcommand{\exampleimg}[1]{%
    \edef\exampleImg{#1}%
  }

  \newcommand{\makemetric}{%
    {
      \footnotesize
      {\noindent\bfseries \sinolSNameHistory:}\par
      \sinolHistory
    }
  }

  \newcommand\exampleinput[1]{%
      \iffileexists{\sinolTestIn/\ID#1.in}{%
          \includefile{\sinolTestIn/\ID#1.in}
      }{
       \iffileexists{\ID#1.in}{%
          \includefile{\ID#1.in}
       }{
         \smallskip
         \?{brak pliku {\ttfamily\ID#1.in}}\par
         \erroutput{brak pliku '\ID#1.in'}
         \smallskip
       }
      }
  }

  \newcommand\exampleoutput[1]{%
    \iffileexists{\sinolTestOut/\ID#1.out}{%
      \includefile{\sinolTestOut/\ID#1.out}
    }{
      \iffileexists{\ID#1.out}{%
         \includefile{\ID#1.out}
      }{
       \smallskip
       \?{brak pliku {\ttfamily\ID#1.out}}\par
       \erroutput{brak pliku '\ID#1.out'}
       \smallskip
      }
    }
  }

  \def\sinolTestIn{../in}

  \def\sinolTestOut{../out}

  \def\@exampleputtogetherh#1#2{\twocol{#1}{#2}}

  \def\@exampleputtogetherv#1#2{#1 #2}

  \newcommand\makestandardexampleinput[1]{%
    \noindent\sinolExampleInputText
    \ifundef{exampleInImg}{%
      \exampleinput{#1}
    }{
      \@exampleputtogetherimg{\exampleinput{#1}}{\plainimg{\exampleInImg}}
    }
  }

  \newcommand\makestandardexampleoutput[1]{%
    \noindent\sinolExampleOutputText
    \ifundef{exampleOutImg}{%
      \exampleoutput{#1}
    }{
      \@exampleputtogetherimg{\exampleoutput{#1}}{\plainimg{\exampleOutImg}}
    }
  }

  \newcommand{\loadtestdir}{
    \openin\tmpfile testdir.inp
    \ifeof\tmpfile
% TW, zazwyczaj ten plik nie jest stosowany, wiec komunikat o bledzie nie jest
%     konieczny
%      \write16{SINOL: brak pliku 'testdir.inp'}
    \else
      \read\tmpfile to\sinolTestIn
      \ifeof\tmpfile
        \write16{SINOL: plik 'testdir.inp' skonczyl sie zbyt wczesnie}
      \else
        \read\tmpfile to\sinolTestOut
      \fi
    \fi
    \closein\tmpfile
  }

  \newcommand\@makestandardexampletext[1]{%
    \@exampleputtogethertext{%
      \makestandardexampleinput{#1}
    }{%
      \makestandardexampleoutput{#1}
    }
  }

  \newcommand\@makeexample[1]{%
    \loadtestdir
    \ifundef{exampleImg}{%
      \@makestandardexampletext{#1}
    }{%
      \@exampleputtogetherimg{%
        \@makestandardexampletext{#1}
      }{
        \plainimg{\exampleImg}
      }
    }
  }


  \newcommand\makestandardexample[1]{%
    \let\@exampleputtogetherimg=\@exampleputtogetherh
    \let\@exampleputtogethertext=\@exampleputtogetherv
    \@makeexample{#1}
  }

  \newcommand\makecompactexample[1]{%
    \def\@exampleputtogetherimg##1##2{%
      \@exampleputtogetherv{##1}{%
        \begin{center}
          ##2
        \end{center}
      }
    }
    \let\@exampleputtogethertext=\@exampleputtogetherh
    \@makeexample{#1}
  }

  \renewcommand{\concludedecls}{%
    \ifundef{ID}{%
      \erroutput{brak 3-literowego identyfikatora (klauzula \string\id)}%
      \def\ID{XXX}%
    }{}%
    \def\infile{{\ttfamily \lcase{\ID}.in}}%
    \def\outfile{{\ttfamily \lcase{\ID}.out}}%
    \ifundef{sinolTitle}{%
      \erroutput{brak tytulu (klauzula \string\title)}%
      \def\sinolTitle{\?{brak tytu^^b3u}}%
    }{}%
    \ifzawodnik%
      \def\sinolIdSignature{\ucase{\ID}}%
    \else%
      \def\sinolIdSignature{\ID/\sinolSignature}%
    \fi%
    \let\oldsection\section%
    \renewcommand{\section}[1]{%
      \def\@tmparg{##1}%
      \oldsection*{##1}%
      \ifnum\sinolSectionNumber=0%
        %\ifeq{\@tmparg}{\sinolSNameZadanie}{%
        %  \sinolSectionNumber=1%
        %}%
      \fi%
      \ifcase\sinolSectionNumber%
        \ifneq{\@tmparg}{\sinolSNameExample}{%
          \erroutputWrongSection{\@tmparg}{\sinolSNameExample}%
        }%
      \or%
        %\ifneq{\@tmparg}{\sinolSNameZadanie}{%
        %  \erroutputWrongSection{##1}{\sinolSNameZadanie}%
        %}%
      \or%
        \ifneq{\@tmparg}{\sinolSNameInput}{%
          \erroutputWrongSection{##1}{\sinolSNameInput}%
        }%
      \or%
        \ifneq{\@tmparg}{\sinolSNameOutput}{%
          \erroutputWrongSection{##1}{\sinolSNameOutput}%
        }%
      \or%
        \ifneq{\@tmparg}{\sinolSNameExample}{%
          \erroutputWrongSection{\@tmparg}{\sinolSNameExample}%
        }%
      \else%
        %\ifneq{\@tmparg}{\sinolSNameUwagi}{%
        %  \erroutput{nadmiarowy rozdzial '##1'}%
        %}%
      \fi%
      \advance\sinolSectionNumber+1%
    }%
  }%

  \renewcommand{\concludetext}{
    \ifnum\sinolSectionNumber=5\else
      \erroutput{niewlasciwa liczba rozdzialow}
    \fi
    \ifeq{\cstyle}{appendix}{\showComments}
  }
}

\DeclareOption{rec}{%
  \def\sinolcat{rec}
  \def\xsinolcat{\sinolTitleRecenzja}
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }
  \newcommand{\id}[1]{%
    \edef\ID{#1}%
    \infoutput{[id][#1]}%
  }
  \newcommand{\makemetric}{%
    {
      \footnotesize
      {\noindent\bfseries \sinolSNameHistory:}\par
      \sinolHistory
    }
  }
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }

  \renewcommand{\concludedecls}{%
    \ifundef{ID}{%
      \def\ID{XXX}%
    }{}%
    \ifundef{sinolTitle}{%
      \def\sinolTitle{\?{tytu^^b3 zostanie wygenerowany}}%
    }{}%
    \def\sinolIdSignature{\ID/\sinolSignature}%
  }%
}

\DeclareOption{opr}{%
  \def\sinolcat{opr}
  \def\xsinolcat{\sinolTitleOpracowanie}
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }
  \newcommand{\id}[1]{%
    \edef\ID{#1}%
    \infoutput{[id][#1]}%
  }
  \newcommand{\makemetric}{%
    {
      \footnotesize
      {\noindent\bfseries \sinolSNameHistory:}\par
      \sinolHistory
    }
  }
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }

  \renewcommand{\concludedecls}{%
    \ifundef{ID}{%
      \def\ID{XXX}%
    }{}%
    \def\infile{{\ttfamily \lcase{\ID}.in}}%
    \def\outfile{{\ttfamily \lcase{\ID}.out}}%
    \ifundef{sinolTitle}{%
      \def\sinolTitle{\?{tytu^^b3 zostanie wygenerowany}}%
    }{}%
    \def\sinolIdSignature{\ucase{\ID}}%
    %
    \newif\ifsectionPresentTesty \sectionPresentTestyfalse%
    \newif\ifsectionPresentRozwiazanieWzorcowe%
         \sectionPresentRozwiazanieWzorcowefalse%
    %
    \let\oldsection\section%
    \renewcommand{\section}[1]{%
      \def\@tmparg{##1}%
      \oldsection{##1}%
      \ifx\@tmparg\sinolSNameTesty%
        \ifsectionPresentTesty%
          \erroutput{powtorzony rozdzial '\@tmparg'}%
        \else%
          \global\sectionPresentTestytrue%
        \fi%
      \fi%
      \ifx\@tmparg\sinolSNameRozwiazanieWzorcowe%
        \ifsectionPresentRozwiazanieWzorcowe%
          \erroutput{powtorzony rozdzial '\@tmparg'}%
        \else%
          \global\sectionPresentRozwiazanieWzorcowetrue%
        \fi%
      \fi%
    }%
  }%

  \renewcommand{\concludetext}{
    \ifidealSolutionPresent\else
      \erroutput{brak odniesienia do rozwiazania optymalnego}
    \fi
    \ifsectionPresentTesty\else
      \erroutput{brak rozdzialu '\sinolSNameTesty'}
    \fi
    \ifsectionPresentRozwiazanieWzorcowe\else
      \erroutput{brak rozdzialu '\sinolSNameRozwiazanieWzorcowe'}
    \fi
  }

  \newif\ifidealSolutionPresent \idealSolutionPresentfalse

  \newcommand{\solution}[1]{%
    \infoutput{[solution][##1]}%
    \infoutput{[uses][prog/##1]}%
    {\ttfamily prog/\ID#1}%
    \def\@tmparg{#1}
    \ifx\@tmparg\sinolSolNameC
      \idealSolutionPresenttrue
    \fi
    \ifx\@tmparg\sinolSolNameCPP
      \idealSolutionPresenttrue
    \fi
    \ifx\@tmparg\sinolSolNamePAS
      \idealSolutionPresenttrue
    \fi
  }

  \newenvironment{tests}{%
    \newcommand{\test}[3]{%
      \item {\ttfamily \ID##1.IN} ($##2$ sek.) ##3\par
      \infoutput{[test][##1]}
      \infoutput{[uses][in/##1.in]}
      \infoutput{[uses][out/##1.in]}
    }
    \begin{itemize}
  }{%
    \end{itemize}
  }
}


\DeclareOption{wer}{%
  \def\sinolcat{wer}
  \def\xsinolcat{\sinolTitleWeryfikacja}
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }
  \newcommand{\id}[1]{%
    \edef\ID{#1}%
    \infoutput{[id][#1]}%
  }
  \newcommand{\makemetric}{%
    {
      \footnotesize
      {\noindent\bfseries \sinolSNameHistory:}\par
      \sinolHistory
    }
  }
  \renewcommand{\title}[1]{%
    \def\sinolTitle{#1}%
    \infoutput{[title][#1]}%
  }

  \newcommand{\solution}[1]{%
    \infoutput{[solution][##1]}%
    \infoutput{[uses][prog/##1]}%
    {\ttfamily prog/\ID#1}%
    \def\@tmparg{#1}
    \ifx\@tmparg\sinolSolNameC
      \idealSolutionPresenttrue
    \fi
    \ifx\@tmparg\sinolSolNameCPP
      \idealSolutionPresenttrue
    \fi
    \ifx\@tmparg\sinolSolNamePAS
      \idealSolutionPresenttrue
    \fi
  }

  \renewcommand{\concludedecls}{%
    \ifundef{ID}{%
      \def\ID{XXX}%
    }{}%
    \ifundef{sinolTitle}{%
      \def\sinolTitle{\?{tytu^^b3 zostanie wygenerowany}}%
    }{}%
    \def\sinolIdSignature{\ID/\sinolSignature}%
  }%
}

\DeclareOption{zawodnik}{%
  \global\zawodniktrue
  \ifx\sinolcat\sinolCatNameZad
    \global\metricfalse
    \renewcommand{\?}[1]{%
      [[[#1]]]%
      \errmessage{SINOL: przy opcji 'zawodnik' nie wolno uzywac %
        '\string\?\string{...\string}'}
    }
  \else
    \errmessage{SINOL: opcja 'zawodnik' moze wystepowac tylko po opcji 'zad'}
  \fi
}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\PassOptionsToClass{a4paper}{article}
\LoadClass{article}
%% \RequirePackage{polski}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rozmiar papieru
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\setlength{\textwidth}{168mm} %{180mm}
\setlength{\textheight}{257mm}
\setlength{\oddsidemargin}{0pt}
\setlength{\topmargin}{0pt}
\setlength{\hoffset}{-4mm} % this means 1in-15mm
\setlength{\voffset}{-20mm} % this means 1in-15mm
\setlength{\topmargin}{0pt}
%% w przypadku stylu fancy, trzeba wyłączyć rysowanie linii w nagłówku
%\headrulewidth 0pt
\renewcommand{\headrulewidth}{0pt}
%\oldtitle{}
%\oldauthor{}
%\date{}

\newenvironment{tasktext}{%
  \expandafter\selectlanguage\expandafter{\sinolLang}%
  \expandafter\inputencoding\expandafter{\sinolInputEncoding}%
  \ifsignaturedefed\else%
    \erroutput{brak sygnatury}%
  \fi%
  %% definiowanie stopek dla stylu fancy
  \ifeq{\sinolPageStyle}{fancy}{%
    \lfoot{\ifDocVersiondefed v.\,\sinolDocVersion \fi}%
%%    \cfoot{\thepage/\pageref{koniec}}%
%%    \rfoot{\sinolTitle}%
    \cfoot{}
    \rfoot{\textbf{\sinolTitle{} \thepage{}/\pageref{koniec}}}
  }%
  \concludedecls%
  {%
    %\sffamily\bfseries
    %\LARGE
    %\leftline{\xsinolcat: \sinolIdSignature}
    %\leftline{\sinolTitle}
    \leftline{%
      \begin{minipage}[t]{0.8\textwidth}
        \sffamily\bfseries%
        \LARGE%
        \xsinolcat: \sinolIdSignature\\
        \sinolTitle
      \end{minipage}
      \begin{minipage}[t]{0.1\textwidth}
        \sffamily\bfseries%
        \large%
        \center
        \ifCountrydefed
          %\sinolTitleCountry:
          \sinolCountry
        \fi
      \end{minipage}
    }%
  }%
  \ifzawodnik
    \hbox to\hsize{\hfil\LOGO}\medskip   %\smallskip
  \else
    \medskip
  \fi
  \hrule
  \smallskip
  \ifmetric
    \makemetric
    \smallskip
    \hrule
  \fi
  \ifzawodnik
    \smallskip
    \hbox to\hsize{%
      {\bf
        \def\@tempempty{}%
        %% Konkurs pokazuje się tylko gdy jest niepusty
        \ifkonkursdefed%
          \ifx\sinolKonkurs\@tempempty,\ %
          \else%
            %\sinolKonkursText%
            \sinolKonkurs %
          \fi%
        \else\?{brak}\erroutput{brak konkursu}\fi%
        \ifdaydefed%
          \ifx\sinolDay\@tempempty.
          \else,
            \sinolDayText:\
            \sinolDay.
          \fi%
        \else\?{brak}\erroutput{brak dnia}\fi%
      }%
    %}%
    %\smallskip
    %\hbox to\hsize{%
      \bf
      %% Dostępna pamięć -- pokazuje sie tylko gdy
      %% nie jest pusta i jest zdefiniowana
      \ifRAMdefed%
        \ifx\sinolRAM\@tempempty%
        \else%
          \sinolRAMText:\
          \sinolRAM\,MB.
        \fi%
      \else\fi%
      %% Maksymalny czas działania -- pokazuje się tylko gdy nie
      %% jest pusty i jest zdefiniowany.
      \iftimedefed%
        \ifx\sinolTime\@tempempty%
        \else%
          \sinolTimeText:\
          \sinolTime.
        \fi%
      \else\fi%
    \hbox to 0pt {\vbox to 0pt {\begin{itemize} \item[] \end{itemize}\vss}}
    % TI: Powyzsza linijka to smutny hak, ktory wymusza, zeby itemize'y
    % generowaly prawidlowe odstepy. Nie wiem dlaczego to dziala, nie wiem dlaczego
    % bez tego nie dziala. Have fun.
      \hfill
      \ifdatedefed{\it\sinolDate}\else\?{brak daty}\erroutput{brak daty}\fi
    }
    \bigskip
  \else
    \vskip1.5pt
    {\tiny\rightline{%
      dokument systemu SINOL \sinolVersion
    }}
    \smallskip
  \fi
  \noindent
  \ignorespacesafterend
}{%
  %\smallskip
  %\finalclause
  \concludetext
  \closeout\inffile
  \closeout\errfile
  \label{koniec}%
}

% Odstepy w itemize
\def\@listi{\leftmargin\leftmargini
   \parsep 0\p@ \@plus1\p@ \@minus\p@
   \partopsep 3\p@ \@plus1\p@ \@minus\p@
      \topsep 3\p@ \@plus1\p@ \@minus0\p@
      \itemsep 3\p@ \@plus1\p@ \@minus\p@}
\let\@listI\@listi
