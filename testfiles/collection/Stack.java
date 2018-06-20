package examples.collection;


//import mungo.lib.Typestate;

@Typestate("CollectionProtocol")
//@Typestate
public class Stack{
	private Node head;
	public Stack () {
	}

	public void initialise(int i) {
		head = null;
	}

	public 	void put(Node n) {
		head = n.next(head);
	}

	public 	Node get() {
		Node tmp = head;
		head = head.next();
		return tmp;
	}

	public 	BooleanChoice isEmpty() {
		if(head == null)
			return BooleanChoice.TRUE;
		return BooleanChoice.FALSE;
	}

	public 	void close() {
	}

	public static void main(String []args) {
		Stack s = new Stack();
		s.initialise(0);

		s.put(new Node(0));
		s.put(new Node(1));

		int i = 2;

		do {
			s.put(new Node(i++));
		} while(i < 42);

		loop: do {
			Node n = s.get();
			System.out.println(n.get());
			switch(s.isEmpty()) {
				case TRUE:
					break loop;

				case FALSE:
					continue loop;
			}
		} while(true);

		s.close();
	}
}
