\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sreport}[2019/10/03 Informal Double-spaced LaTeX Short Report Class]

\DeclareOption*{%
    \PassOptionsToClass{\CurrentOption}{article}%
}
\DeclareOption{narrow}{%
    \AtEndOfPackage{\geometry{margin = 1.27cm}
	\resetHeadWidth%
	}%
}
\DeclareOption{moderate}{%
    \AtEndOfPackage{\geometry{top = 2.54 cm%
        bottom = 2.54cm%
        left = 1.91cm%
        right = 1.91cm%
    }
	\resetHeadWidth%
	}
}
\DeclareOption{wide}{%
    \AtEndOfPackage{\geometry{top = 2.54 cm%
    bottom = 2.54cm%
    left = 5.08cm%
    right = 5.08cm%
    }
	\resetHeadWidth%
	}
}
\DeclareOption{doublespacing}{%
  \AtEndOfPackage{%
    \setstretch{2}%
    }
}
\DeclareOption{singlespacing}{%
  \AtEndOfPackage{%
    \setstretch{1}%
    }
}
\DeclareOption{onehalfspacing}{%
  \AtEndOfPackage{%
    \setstretch{1.5}%
    }
}
\DeclareOption{sas}{%
  \AtEndOfPackage{%
    \input{listings_sas.tex}%
  }
}
\DeclareOption{stata}{%
  \AtEndOfPackage{%
    \input{listings_stata.tex}%
  }
}
\ProcessOptions\relax

\LoadClass{article}

\renewcommand{\maketitle}{%
    \begin{center}%
    \setstretch{1}
    {\normalsize \bfseries \@title \par}%
    {\normalsize%
      \vspace*{1 em}
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
  \end{center}%
  \par%
  \thispagestyle{fancy}
}

% UTF8
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}

% Page Margin
\RequirePackage{geometry}%
\geometry{margin = 2.54cm}%

% Line Space
\RequirePackage{setspace}%
\RequirePackage{etoolbox}%
\setstretch{2}
\AtBeginEnvironment{tabular}{\setstretch{1}}
\AtBeginEnvironment{longtable}{\setstretch{1}}
\AtBeginEnvironment{tabularx}{\setstretch{1}}
\AtBeginEnvironment{tabu}{\setstretch{1}}
\AtBeginEnvironment{longtabu}{\setstretch{1}}
\AtBeginEnvironment{equation}{\setstretch{1}}
\AtBeginEnvironment{align}{\setstretch{1}}
\AtBeginEnvironment{equation*}{\setstretch{1}}
\AtBeginEnvironment{align*}{\setstretch{1}}
\AtBeginEnvironment{tabule}{\centering\small}
\AtBeginEnvironment{figure}{\centering\small}
\AtBeginEnvironment{tabular}{\small}
\AtBeginEnvironment{lstlisting}{\setstretch{1}}
\AtBeginEnvironment{gather}{\setstretch{1}}
\AtBeginEnvironment{gather*}{\setstretch{1}}

% References
\RequirePackage[english]{babel}%
\RequirePackage{csquotes,xpatch}%
\RequirePackage[
backend = biber
, authordate
, citetracker=true
, sortcites=true
, sorting=nyt
, pagetracker=true
, minnames=1
, maxcitenames=1
, natbib
, includeall=false
, doi=true
]{biblatex-chicago}
\urlstyle{same}
\AtEveryCitekey{\ifciteseen{}{\defcounter{maxnames}{99}}}

% Header and Footer
\RequirePackage{fancyhdr}
\pagestyle{fancy}
\fancyhead{}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0.0pt}
\makeatletter
  \ifcsname f@nch@setoffs\endcsname\else%
  %% If \fancy@setoffs does not exis, then we assume old version define it to be
  %% fancy@setoffs, which is the old name for it:
  \let\f@nch@setoffs\fancy@setoffs
\fi
\makeatother
\makeatletter
\newcommand{\resetHeadWidth}{\f@nch@setoffs}
\makeatother

% Math
\RequirePackage{amsmath, amsfonts, amssymb, mathtools, ntheorem, bm}

% Times New Roman Font
\RequirePackage[T1]{fontenc}
\RequirePackage{newtxtext,newtxmath}

% Title Format
\RequirePackage{titlesec}
\titleformat*{\section}{\normalsize\bfseries}{}{}{}{}
\titlespacing{\section}{0pt}{*1}{*1}
\titleformat*{\subsection}{\normalsize\bfseries}{}{}{}{}
\titlespacing{\subsection}{0pt}{*1}{*1}
\titleformat*{\subsubsection}{\normalsize\bfseries}{}{}{}{}
\titlespacing{\subsubsection}{0pt}{*1}{*1}
\titleformat*{\paragraph}{\normalsize\bfseries}{}{}{}{}
\titlespacing{\paragraph}{0pt}{*1}{*1}
\titleformat*{\subparagraph}{\normalsize\bfseries}{}{}{}{}
\titlespacing{\subparagraph}{0pt}{*1}{*1}

% Table
\RequirePackage{booktabs}
\RequirePackage{tabularx}
\RequirePackage{longtable}

% Float
\RequirePackage{float}
\RequirePackage{caption}
\RequirePackage{subcaption}
\floatstyle{plaintop}
\restylefloat{table}
\restylefloat{figure}
\captionsetup{font=normalsize
  , labelfont=bf
  , justification=centering}

% Listings
\RequirePackage{listings}
\lstset{%
  breaklines=true,
  frame=single,
  numbers=left
}
\RequirePackage{listings}
\RequirePackage[svgnames]{xcolor}
\RequirePackage{color}

% Changes
\RequirePackage[commentmarkup = footnote,
highlightmarkup=uuline]{changes}