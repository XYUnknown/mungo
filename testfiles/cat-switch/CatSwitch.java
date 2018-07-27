package examples.cat;

class CatSwitch {
	public static void main(String[] args) {
		// Switch statement
		Cat cat2 = new Cat();
		cat2.initialise();
		cat2.putInBox();
		//BooleanChoice result;  // not valid
		//result = cat2.openBox(); // not valid
		switch (cat2.openBox()) {			
			case FALSE:
				cat2.bury();
				break;
			case TRUE:				
				cat2.giveBirth();
				//cat2.giveBirth();
				cat2.poison();
				cat2.bury(); // Error detected
				break;
			case "foo": // Error detected
				cat2.bury(); // Error detected
				break;			
			default:
				cat2.close(); // Error detected			
		}
		cat2.poison(); // Error detected 


		// Nested Switch statement
		Cat cat0 = new Cat();
		Cat cat1 = new Cat();
		cat0.initialise();
		cat0.poison();
		cat1.initialise();
		cat0.putInBox();
		cat1.putInBox();
		//BooleanChoice result; // not valid
		//result = cat1.openBox(); // not valid
		switch (cat1.openBox()) {			
			case FALSE:
				switch (cat0.openBox()){
					case TRUE:
						cat0.giveBirth();
						cat0.close();
						cat1.bury();
						break;
					case FALSE:
						cat0.bury();
						cat1.bury();
						break;
				}
				//cat1.bury();
				break;
			case TRUE:
				switch (cat0.openBox()){
					case TRUE:
						cat0.giveBirth();
						cat0.close();
						break;
					case FALSE:
						cat0.bury();
						break;
				}				
				cat1.close();
				break;
		}
	}
}