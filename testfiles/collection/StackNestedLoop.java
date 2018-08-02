package examples.collection;

class StackNestedLoop {
	public static void main(String []args) {
		Stack s0 = new Stack();
		s0.initialise(0);
		int i = 0;

		do {
			s0.put(new Node(i++));
		} while(i < 42);

		Stack s1 = new Stack();
		s1.initialise(0);
		int j = 0;
		do {
			s1.put(new Node(j++));
		} while(j < 42);
		s1.get();

		outer: do {
			Node n = s0.get();
			System.out.println(n.get());			
			switch(s0.isEmpty()) {
				case TRUE:
					inner: do {
						//s1.get();
						switch(s1.isEmpty()) {
							case TRUE:
								break inner;
							case FALSE:
								s1.get();
								continue inner;
						}
					} while(true);
					//s1.close();
					break outer;
				case FALSE:					
					inner1: do {
						//s1.get();
						switch(s1.isEmpty()) {
							case TRUE:
								break inner1;
							case FALSE:
								s1.get();
								continue inner1;
						}
					} while(true);
					//s1.close();
					continue outer;
			}
		} while(true);

		s0.close();
		s1.close();
	}
}