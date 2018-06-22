<YYINITIAL> {
	/** The Typestate annotation in java source file */
	"Typestate"    { return sym(Terminals.TYPESTATEANNO); }
	/** The `typestate` keyword in protocol file */
	"typestate"     { return sym(Terminals.TYPESTATE); }
	/** The `end` in protocol file as a keyword is classified */
	"end"           { return sym(Terminals.END); }
}
