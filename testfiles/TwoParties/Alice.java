package examples.TwoParties;

//import mungo.lib.Typestate;

import java.net.Socket;
import java.io.IOException;

@Typestate("AliceProtocol")
class Alice{
	private SessionSocket bob;
	private int port;

	public Alice(int port) {
		this.port = port;
	}

	void connect() {
		try {
			bob = new SessionSocket(new Socket("localhost", port));
		}
		catch(IOException e) {
			e.printStackTrace();
			System.exit(-1);
		}
	}

	String recvStringFromBob() {
		return bob.recvString();
	}

	void sendTimeToBob(int i) {
		bob.send(i);
	}

	BobChoice choiceFromBob() {
		return (BobChoice) bob.recvObject();
	}

	void sendGreetToBob(String s) {
		bob.send(s);
	}

	void endCommunication() {
		bob.close();
	}
}
