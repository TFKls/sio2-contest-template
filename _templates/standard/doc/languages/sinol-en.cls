\DeclareOption{en}{%
	\def\sinolLang{english}
	\def\sinolLangShow{english}
	
	\def\sinolTitleTask{Task}
	\def\sinolSNameZadanie{Task}
	\def\sinolSNameExample{Examples}
	\def\sinolSNameInput{Input}
	\def\sinolSNameOutput{Output}
	\def\sinolSNameExampleExplanation{\medskip
		\noindent
		\textbf{Explanation to the examples:}
	}
	
	\def\sinolDayText{day}
	\def\sinolRAMText{Available memory}
	
	\def\sinolSNameGrading{Grading}
	\def\sinolSNameSubtask{Subtask}
	\def\sinolSNameConditions{Conditions}
	\def\sinolSNamePoints{Points}
	\def\sinolSNameTimeLimit{Time limit}
	
	\renewcommand{\iomode}[1]{
		\def\sinolIOmode{#1}
		\ifeq{#1}{stdin}{
			\gdef\sinolExampleInputText{For the input data:}
			\gdef\sinolExampleOutputText{a correct result is:}
		}
	}
}
