\DeclareOption{cz}{%
	\def\sinolLang{czech}
	\def\sinolLangShow{czech}
	
	\def\sinolTitleTask{\'Uloha}
	\def\sinolSNameExample{P\v{r}{\'\i}klad}
	\def\sinolSNameInput{Vstup}
	\def\sinolSNameOutput{V\'ystup}
	\def\sinolDayText{Den}
	\def\sinolRAMText{Dostupn\'a pam\v{e}t'}
	\def\sinolSNameExampleExplanation{\medskip
		\noindent
		\textbf{Vysvětlení příkladů:}
	}
	
	\def\sinolSNameGrading{Hodnocení}
	\def\sinolSNameSubtask{Podúloha}
	\def\sinolSNameConditions{Další omezení}
	\def\sinolSNamePoints{Body}
	\def\sinolSNameTimeLimit{Časový limit}
	
	\renewcommand{\iomode}[1]{
		\def\sinolIOmode{#1}
		\ifeq{#1}{stdin}{
			\gdef\sinolExampleInputText{Pro vstupn{\'\i} data:}
			\gdef\sinolExampleOutputText{je spr\'avn\'y v\'ystup:}
		}
	}
}
