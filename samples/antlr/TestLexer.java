// $ANTLR 3.1.1 Test__.g 2008-11-22 15:50:27

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

public class TestLexer extends Lexer {
    public static final int EOF=-1;
    public static final int T__6=6;
    public static final int T__5=5;
    public static final int T__4=4;

    // delegates
    // delegators

    public TestLexer() {;} 
    public TestLexer(CharStream input) {
        this(input, new RecognizerSharedState());
    }
    public TestLexer(CharStream input, RecognizerSharedState state) {
        super(input,state);

    }
    public String getGrammarFileName() { return "Test__.g"; }

    // $ANTLR start "T__4"
    public final void mT__4() throws RecognitionException {
        try {
            int _type = T__4;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // Test__.g:3:6: ( 'A' )
            // Test__.g:3:8: 'A'
            {
            match('A'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "T__4"

    // $ANTLR start "T__5"
    public final void mT__5() throws RecognitionException {
        try {
            int _type = T__5;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // Test__.g:4:6: ( 'B' )
            // Test__.g:4:8: 'B'
            {
            match('B'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "T__5"

    // $ANTLR start "T__6"
    public final void mT__6() throws RecognitionException {
        try {
            int _type = T__6;
            int _channel = DEFAULT_TOKEN_CHANNEL;
            // Test__.g:5:6: ( 'C' )
            // Test__.g:5:8: 'C'
            {
            match('C'); 

            }

            state.type = _type;
            state.channel = _channel;
        }
        finally {
        }
    }
    // $ANTLR end "T__6"

    public void mTokens() throws RecognitionException {
        // Test__.g:1:8: ( T__4 | T__5 | T__6 )
        int alt1=3;
        switch ( input.LA(1) ) {
        case 'A':
            {
            alt1=1;
            }
            break;
        case 'B':
            {
            alt1=2;
            }
            break;
        case 'C':
            {
            alt1=3;
            }
            break;
        default:
            NoViableAltException nvae =
                new NoViableAltException("", 1, 0, input);

            throw nvae;
        }

        switch (alt1) {
            case 1 :
                // Test__.g:1:10: T__4
                {
                mT__4(); 

                }
                break;
            case 2 :
                // Test__.g:1:15: T__5
                {
                mT__5(); 

                }
                break;
            case 3 :
                // Test__.g:1:20: T__6
                {
                mT__6(); 

                }
                break;

        }

    }


 

}