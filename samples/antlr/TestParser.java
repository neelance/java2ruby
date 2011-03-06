// $ANTLR 3.1.1 samples/antlr/Test.g 2008-11-25 22:23:29

import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

import org.antlr.runtime.debug.*;
import java.io.IOException;
public class TestParser extends DebugParser {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "'A'", "'B'", "'C'"
    };
    public static final int EOF=-1;
    public static final int T__6=6;
    public static final int T__5=5;
    public static final int T__4=4;

    // delegates
    // delegators

    public static final String[] ruleNames = new String[] {
        "invalidRule", "b", "root"
    };
     
        public int ruleLevel = 0;
        public int getRuleLevel() { return ruleLevel; }
        public void incRuleLevel() { ruleLevel++; }
        public void decRuleLevel() { ruleLevel--; }
        public TestParser(TokenStream input) {
            this(input, DebugEventSocketProxy.DEFAULT_DEBUGGER_PORT, new RecognizerSharedState());
        }
        public TestParser(TokenStream input, int port, RecognizerSharedState state) {
            super(input, state);
            DebugEventSocketProxy proxy =
                new DebugEventSocketProxy(this, port, null);
            setDebugListener(proxy);
            try {
                proxy.handshake();
            }
            catch (IOException ioe) {
                reportError(ioe);
            }
        }
    public TestParser(TokenStream input, DebugEventListener dbg) {
        super(input, dbg, new RecognizerSharedState());

    }
    protected boolean evalPredicate(boolean result, String predicate) {
        dbg.semanticPredicate(result, predicate);
        return result;
    }


    public String[] getTokenNames() { return TestParser.tokenNames; }
    public String getGrammarFileName() { return "samples/antlr/Test.g"; }



    // $ANTLR start "root"
    // samples/antlr/Test.g:3:1: root : 'A' ( b )* ;
    public final void root() throws RecognitionException {
        try { dbg.enterRule(getGrammarFileName(), "root");
        if ( getRuleLevel()==0 ) {dbg.commence();}
        incRuleLevel();
        dbg.location(3, 1);

        try {
            // samples/antlr/Test.g:3:6: ( 'A' ( b )* )
            dbg.enterAlt(1);

            // samples/antlr/Test.g:3:8: 'A' ( b )*
            {
            dbg.location(3,8);
            match(input,4,FOLLOW_4_in_root10); 
            dbg.location(3,12);
            // samples/antlr/Test.g:3:12: ( b )*
            try { dbg.enterSubRule(1);

            loop1:
            do {
                int alt1=2;
                try { dbg.enterDecision(1);

                int LA1_0 = input.LA(1);

                if ( ((LA1_0>=5 && LA1_0<=6)) ) {
                    alt1=1;
                }


                } finally {dbg.exitDecision(1);}

                switch (alt1) {
            	case 1 :
            	    dbg.enterAlt(1);

            	    // samples/antlr/Test.g:3:12: b
            	    {
            	    dbg.location(3,12);
            	    pushFollow(FOLLOW_b_in_root12);
            	    b();

            	    state._fsp--;


            	    }
            	    break;

            	default :
            	    break loop1;
                }
            } while (true);
            } finally {dbg.exitSubRule(1);}


            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        dbg.location(3, 14);

        }
        finally {
            dbg.exitRule(getGrammarFileName(), "root");
            decRuleLevel();
            if ( getRuleLevel()==0 ) {dbg.terminate();}
        }

        return ;
    }
    // $ANTLR end "root"


    // $ANTLR start "b"
    // samples/antlr/Test.g:5:1: b : ( 'B' | 'C' ) ;
    public final void b() throws RecognitionException {
        try { dbg.enterRule(getGrammarFileName(), "b");
        if ( getRuleLevel()==0 ) {dbg.commence();}
        incRuleLevel();
        dbg.location(5, 1);

        try {
            // samples/antlr/Test.g:5:3: ( ( 'B' | 'C' ) )
            dbg.enterAlt(1);

            // samples/antlr/Test.g:5:5: ( 'B' | 'C' )
            {
            dbg.location(5,5);
            if ( (input.LA(1)>=5 && input.LA(1)<=6) ) {
                input.consume();
                state.errorRecovery=false;
            }
            else {
                MismatchedSetException mse = new MismatchedSetException(null,input);
                dbg.recognitionException(mse);
                throw mse;
            }


            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }
        finally {
        }
        dbg.location(5, 16);

        }
        finally {
            dbg.exitRule(getGrammarFileName(), "b");
            decRuleLevel();
            if ( getRuleLevel()==0 ) {dbg.terminate();}
        }

        return ;
    }
    // $ANTLR end "b"

    // Delegated rules


 

    public static final BitSet FOLLOW_4_in_root10 = new BitSet(new long[]{0x0000000000000062L});
    public static final BitSet FOLLOW_b_in_root12 = new BitSet(new long[]{0x0000000000000062L});
    public static final BitSet FOLLOW_set_in_b21 = new BitSet(new long[]{0x0000000000000002L});

}