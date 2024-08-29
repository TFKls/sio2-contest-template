\DeclareOption{pl}{}% this is default, but we want to silence warnings ~tfk
\def\sinolLang{polish}
\def\sinolLangShow{polish}

\def\sinolTitleTask{Zadanie}
\def\sinolSNameExample{Przyk\l ady}
\def\sinolSNameInput{Wej\'scie}
\def\sinolSNameOutput{Wyj\'scie}
\def\sinolSNameExampleExplanation{\medskip
	\noindent
	\textbf{Wyja\'snienie do przyk\l adu:}
}

\def\sinolDayText{dzie\'n}
\def\sinolRAMText{Dost\k epna pami\k e\'c}

\def\sinolSNameGrading{Ocenianie}
\def\sinolSNameSubtask{Podzadanie}
\def\sinolSNameConditions{Ograniczenia}
\def\sinolSNamePoints{Punkty}
\def\sinolSNameTimeLimit{Limit czasu}

\newcommand{\iomode}[1]{
	\def\sinolIOmode{#1}
	\ifeq{#1}{stdin}{
		\gdef\sinolExampleInputText{Dla danych wej\'sciowych:}
		\gdef\sinolExampleOutputText{poprawnym wynikiem jest:}
	}
}
