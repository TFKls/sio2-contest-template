\DeclareOption{sk}{%
	\def\sinolLang{slovak}
	\def\sinolLangShow{slovak}
	
	\def\sinolTitleTask{Úloha}
	\def\sinolSNameZadanie{Úloha}
	\def\sinolSNameExample{Príklady}
	\def\sinolSNameInput{Vstup}
	\def\sinolSNameOutput{Výstup}
	\def\sinolSNameExampleExplanation{\medskip
		\noindent
		\textbf{Komentáre:}
	}
	
	\def\sinolDayText{deň}
	\def\sinolRAMText{Pamäťový limit}
	
	\def\sinolSNameGrading{Hodnotenie}
	\def\sinolSNameSubtask{Podúloha}
	\def\sinolSNameConditions{Ďalšie ohraničenia}
	\def\sinolSNamePoints{Body}
	\def\sinolSNameTimeLimit{Časový limit}
	
	\renewcommand{\iomode}[1]{
		\def\sinolIOmode{#1}
		\ifeq{#1}{stdin}{
			\gdef\sinolExampleInputText{Pre vstup:}
			\gdef\sinolExampleOutputText{je správny výsledok:}
		}
	}
	
}
