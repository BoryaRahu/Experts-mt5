/ / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                             v a 5_ n e t . m q 5   |  
 / / |                                                                                             C o p y r i g h t   2 0 2 2 ,   D N G   |  
 / / |                                                                 h t t p s : / / w w w . m q l 5 . c o m / r u / u s e r s / d n g   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 # p r o p e r t y   c o p y r i g h t   " C o p y r i g h t   2 0 2 2 ,   D N G "  
 # p r o p e r t y   l i n k             " h t t p s : / / w w w . m q l 5 . c o m / r u / u s e r s / d n g "  
 # p r o p e r t y   v e r s i o n       " 1 . 0 0 "  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   I n c l u d e s                                                                                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 # i n c l u d e   " . . \ . . \ N e u r o N e t _ D N G \ N e u r o N e t . m q h "  
 # i n c l u d e   < T r a d e \ S y m b o l I n f o . m q h >  
 # i n c l u d e   < I n d i c a t o r s \ O s c i l a t o r s . m q h >  
 / / - - -  
 # d e f i n e   F i l e N a m e                 S y m b . N a m e ( ) + " _ " + E n u m T o S t r i n g ( ( E N U M _ T I M E F R A M E S ) P e r i o d ( ) ) + " _ " + S t r i n g S u b s t r ( _ _ F I L E _ _ , 0 , S t r i n g F i n d ( _ _ F I L E _ _ , " . " , 0 ) )  
 # d e f i n e   C S V                           _ _ F I L E _ _ + " . c s v "  
 / / - - -  
 e n u m   E N U M _ S I G N A L  
     {  
       S e l l   =   - 1 ,  
       U n d e f i n e   =   0 ,  
       B u y   =   1  
     } ;  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |       i n p u t   p a r a m e t e r s                                                                                               |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n p u t   i n t                                     S t u d y P e r i o d   =     1 5 ;                         / / S t u d y   p e r i o d ,   y e a r s  
 i n p u t   u i n t                                   i H i s t o r y B a r s   =     4 0 ;                         / / D e p t h   o f   h i s t o r y  
 u i n t   H i s t o r y B a r s   =   1 ;  
 i n p u t   E N U M _ T I M E F R A M E S                         T i m e F r a m e       =     P E R I O D _ C U R R E N T ;  
 / / - - -  
 i n p u t   g r o u p                                 " - - - -   R S I   - - - - "  
 i n p u t   i n t                                     R S I P e r i o d       =     1 4 ;                         / / P e r i o d  
 i n p u t   E N U M _ A P P L I E D _ P R I C E       R S I P r i c e         =     P R I C E _ C L O S E ;       / / A p p l i e d   p r i c e  
 / / - - -  
 i n p u t   g r o u p                                 " - - - -   C C I   - - - - "  
 i n p u t   i n t                                     C C I P e r i o d       =     1 4 ;                         / / P e r i o d  
 i n p u t   E N U M _ A P P L I E D _ P R I C E       C C I P r i c e         =     P R I C E _ T Y P I C A L ;   / / A p p l i e d   p r i c e  
 / / - - -  
 i n p u t   g r o u p                                 " - - - -   A T R   - - - - "  
 i n p u t   i n t                                     A T R P e r i o d       =     1 4 ;                         / / P e r i o d  
 / / - - -  
 i n p u t   g r o u p                                 " - - - -   M A C D   - - - - "  
 i n p u t   i n t                                     F a s t P e r i o d     =     1 2 ;                         / / F a s t  
 i n p u t   i n t                                     S l o w P e r i o d     =     2 6 ;                         / / S l o w  
 i n p u t   i n t                                     S i g n a l P e r i o d   =     9 ;                         / / S i g n a l  
 i n p u t   E N U M _ A P P L I E D _ P R I C E       M A C D P r i c e       =     P R I C E _ C L O S E ;       / / A p p l i e d   p r i c e  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                                                     |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 C S y m b o l I n f o                   * S y m b ;  
 M q l R a t e s                         R a t e s [ ] ;  
 C B u f f e r F l o a t             * T e m p D a t a ;  
 C i R S I                               * R S I ;  
 C i C C I                               * C C I ;  
 C i A T R                               * A T R ;  
 C i M A C D                             * M A C D ;  
 C N e t                                 * N e t ;  
 / / - - -  
 f l o a t                                 d E r r o r ;  
 d a t e t i m e                           d t S t u d i e d ;  
 b o o l                                   b E v e n t S t u d y ;  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   E x p e r t   i n i t i a l i z a t i o n   f u n c t i o n                                                                       |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 i n t   O n I n i t ( )  
     {  
 / / - - -  
       S y m b   =   n e w   C S y m b o l I n f o ( ) ;  
       i f ( C h e c k P o i n t e r ( S y m b )   = =   P O I N T E R _ I N V A L I D   | |   ! S y m b . N a m e ( _ S y m b o l ) )  
             r e t u r n   I N I T _ F A I L E D ;  
       S y m b . R e f r e s h ( ) ;  
 / / - - -  
       R S I   =   n e w   C i R S I ( ) ;  
       i f ( C h e c k P o i n t e r ( R S I )   = =   P O I N T E R _ I N V A L I D   | |   ! R S I . C r e a t e ( S y m b . N a m e ( ) ,   T i m e F r a m e ,   R S I P e r i o d ,   R S I P r i c e ) )  
             r e t u r n   I N I T _ F A I L E D ;  
 / / - - -  
       C C I   =   n e w   C i C C I ( ) ;  
       i f ( C h e c k P o i n t e r ( C C I )   = =   P O I N T E R _ I N V A L I D   | |   ! C C I . C r e a t e ( S y m b . N a m e ( ) ,   T i m e F r a m e ,   C C I P e r i o d ,   C C I P r i c e ) )  
             r e t u r n   I N I T _ F A I L E D ;  
 / / - - -  
       A T R   =   n e w   C i A T R ( ) ;  
       i f ( C h e c k P o i n t e r ( A T R )   = =   P O I N T E R _ I N V A L I D   | |   ! A T R . C r e a t e ( S y m b . N a m e ( ) ,   T i m e F r a m e ,   A T R P e r i o d ) )  
             r e t u r n   I N I T _ F A I L E D ;  
 / / - - -  
       M A C D   =   n e w   C i M A C D ( ) ;  
       i f ( C h e c k P o i n t e r ( M A C D )   = =   P O I N T E R _ I N V A L I D   | |   ! M A C D . C r e a t e ( S y m b . N a m e ( ) ,   T i m e F r a m e ,   F a s t P e r i o d ,   S l o w P e r i o d ,   S i g n a l P e r i o d ,   M A C D P r i c e ) )  
             r e t u r n   I N I T _ F A I L E D ;  
 / / - - -  
       N e t   =   n e w   C N e t ( N U L L ) ;  
       R e s e t L a s t E r r o r ( ) ;  
       f l o a t   t e m p 1 ,   t e m p 2 ;  
       i f ( ! N e t   | |   ! N e t . L o a d ( F i l e N a m e   +   " . n n w " ,   d E r r o r ,   t e m p 1 ,   t e m p 2 ,   d t S t u d i e d ,   f a l s e ) )  
           {  
             p r i n t f ( " % s   -   % d   - >   E r r o r   o f   r e a d   % s   p r e v   N e t   % d " ,   _ _ F U N C T I O N _ _ ,   _ _ L I N E _ _ ,   F i l e N a m e   +   " . n n w " ,   G e t L a s t E r r o r ( ) ) ;  
             H i s t o r y B a r s   =   i H i s t o r y B a r s ;  
             C A r r a y O b j   * T o p o l o g y   =   n e w   C A r r a y O b j ( ) ;  
             i f ( C h e c k P o i n t e r ( T o p o l o g y )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   0  
             C L a y e r D e s c r i p t i o n   * d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             i n t   p r e v   =   d e s c . c o u n t   =   ( i n t ) 1 0   *   1 2 ;  
             d e s c . t y p e   =   d e f N e u r o n B a s e O C L ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             d e s c . a c t i v a t i o n   =   N o n e ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   1  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e s c . c o u n t   =   p r e v ;  
             d e s c . b a t c h   =   1 0 0 0 ;  
             d e s c . t y p e   =   d e f N e u r o n B a t c h N o r m O C L ;  
             d e s c . a c t i v a t i o n   =   N o n e ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   2  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             p r e v   =   d e s c . c o u n t   =   5 0 0 ;  
             d e s c . t y p e   =   d e f N e u r o n L S T M O C L ;  
             d e s c . a c t i v a t i o n   =   N o n e ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   3  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             p r e v   =   d e s c . c o u n t   =   p r e v / 2 ;  
             d e s c . t y p e   =   d e f N e u r o n L S T M O C L ;  
             d e s c . a c t i v a t i o n   =   N o n e ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   4  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             p r e v   =   d e s c . c o u n t   =   5 0 ;  
             d e s c . t y p e   =   d e f N e u r o n L S T M O C L ;  
             d e s c . a c t i v a t i o n   =   N o n e ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   5  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e s c . c o u n t   =   p r e v / 2 ;  
             d e s c . t y p e   =   d e f N e u r o n V A E O C L ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   6  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e s c . c o u n t   =   ( i n t )   H i s t o r y B a r s ;  
             d e s c . t y p e   =   d e f N e u r o n B a s e O C L ;  
             d e s c . a c t i v a t i o n   =   T A N H ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   7  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e s c . c o u n t   =   ( i n t )   H i s t o r y B a r s   *   2 ;  
             d e s c . t y p e   =   d e f N e u r o n B a s e O C L ;  
             d e s c . a c t i v a t i o n   =   T A N H ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   8  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e s c . c o u n t   =   ( i n t )   H i s t o r y B a r s   *   4 ;  
             d e s c . t y p e   =   d e f N e u r o n B a s e O C L ;  
             d e s c . a c t i v a t i o n   =   T A N H ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             / / - - -   9  
             d e s c   =   n e w   C L a y e r D e s c r i p t i o n ( ) ;  
             i f ( C h e c k P o i n t e r ( d e s c )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e s c . c o u n t   =   ( i n t )   H i s t o r y B a r s   *   1 2 ;  
             d e s c . t y p e   =   d e f N e u r o n B a s e O C L ;  
             d e s c . a c t i v a t i o n   =   T A N H ;  
             d e s c . o p t i m i z a t i o n   =   A D A M ;  
             i f ( ! T o p o l o g y . A d d ( d e s c ) )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d e l e t e   N e t ;  
             N e t   =   n e w   C N e t ( T o p o l o g y ) ;  
             d e l e t e   T o p o l o g y ;  
             i f ( C h e c k P o i n t e r ( N e t )   = =   P O I N T E R _ I N V A L I D )  
                   r e t u r n   I N I T _ F A I L E D ;  
             d E r r o r   =   F L T _ M A X ;  
           }  
       e l s e  
           {  
             C B u f f e r F l o a t   * t e m p ;  
             N e t . g e t R e s u l t s ( t e m p ) ;  
             H i s t o r y B a r s   =   t e m p . T o t a l ( )   /   1 2 ;  
             d e l e t e   t e m p ;  
           }  
 / / - - -  
       T e m p D a t a   =   n e w   C B u f f e r F l o a t ( ) ;  
       i f ( C h e c k P o i n t e r ( T e m p D a t a )   = =   P O I N T E R _ I N V A L I D )  
             r e t u r n   I N I T _ F A I L E D ;  
 / / - - -  
       b E v e n t S t u d y   =   E v e n t C h a r t C u s t o m ( C h a r t I D ( ) ,   1 ,   ( l o n g ) M a t h M a x ( 0 ,   M a t h M i n ( i T i m e ( S y m b . N a m e ( ) ,   P E R I O D _ C U R R E N T ,   ( i n t ) ( 1 0 0   *   N e t . r e c e n t A v e r a g e S m o o t h i n g F a c t o r   *   1 0 ) ) ,   d t S t u d i e d ) ) ,   0 ,   " I n i t " ) ;  
 / / - - -  
       r e t u r n ( I N I T _ S U C C E E D E D ) ;  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   E x p e r t   d e i n i t i a l i z a t i o n   f u n c t i o n                                                                   |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n D e i n i t ( c o n s t   i n t   r e a s o n )  
     {  
 / / - - -  
       i f ( C h e c k P o i n t e r ( S y m b )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   S y m b ;  
 / / - - -  
       i f ( C h e c k P o i n t e r ( R S I )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   R S I ;  
 / / - - -  
       i f ( C h e c k P o i n t e r ( C C I )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   C C I ;  
 / / - - -  
       i f ( C h e c k P o i n t e r ( A T R )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   A T R ;  
 / / - - -  
       i f ( C h e c k P o i n t e r ( M A C D )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   M A C D ;  
 / / - - -  
       i f ( C h e c k P o i n t e r ( N e t )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   N e t ;  
 / / - - -  
       i f ( C h e c k P o i n t e r ( T e m p D a t a )   ! =   P O I N T E R _ I N V A L I D )  
             d e l e t e   T e m p D a t a ;  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   E x p e r t   t i c k   f u n c t i o n                                                                                           |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n T i c k ( )  
     {  
 / / - - -  
       i f ( ! b E v e n t S t u d y   & &   ( d t S t u d i e d   <   S e r i e s I n f o I n t e g e r ( S y m b . N a m e ( ) ,   T i m e F r a m e ,   S E R I E S _ L A S T B A R _ D A T E ) ) )  
             b E v e n t S t u d y   =   E v e n t C h a r t C u s t o m ( C h a r t I D ( ) ,   1 ,   ( l o n g ) 0 ,   0 ,   " N e w   B a r " ) ;  
 / / - - -  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   T r a d e   f u n c t i o n                                                                                                       |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n T r a d e ( )  
     {  
 / / - - -  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   T r a d e T r a n s a c t i o n   f u n c t i o n                                                                                 |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n T r a d e T r a n s a c t i o n ( c o n s t   M q l T r a d e T r a n s a c t i o n &   t r a n s ,  
                                                 c o n s t   M q l T r a d e R e q u e s t &   r e q u e s t ,  
                                                 c o n s t   M q l T r a d e R e s u l t &   r e s u l t )  
     {  
 / / - - -  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |   C h a r t E v e n t   f u n c t i o n                                                                                             |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   O n C h a r t E v e n t ( c o n s t   i n t   i d ,  
                                     c o n s t   l o n g   & l p a r a m ,  
                                     c o n s t   d o u b l e   & d p a r a m ,  
                                     c o n s t   s t r i n g   & s p a r a m )  
     {  
 / / - - -  
       i f ( i d   = =   1 0 0 1 )  
           {  
             T r a i n ( l p a r a m ) ;  
             b E v e n t S t u d y   =   f a l s e ;  
             O n T i c k ( ) ;  
           }  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 / / |                                                                                                                                     |  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 v o i d   T r a i n ( d a t e t i m e   S t a r t T r a i n B a r   =   0 )  
     {  
       i n t   c o u n t   =   0 ;  
 / / - - -  
       M q l D a t e T i m e   s t a r t _ t i m e ;  
       T i m e C u r r e n t ( s t a r t _ t i m e ) ;  
       s t a r t _ t i m e . y e a r   - =   S t u d y P e r i o d ;  
       i f ( s t a r t _ t i m e . y e a r   < =   0 )  
             s t a r t _ t i m e . y e a r   =   1 9 0 0 ;  
       d a t e t i m e   s t _ t i m e   =   S t r u c t T o T i m e ( s t a r t _ t i m e ) ;  
       d t S t u d i e d   =   M a t h M a x ( S t a r t T r a i n B a r ,   s t _ t i m e ) ;  
       u l o n g   l a s t _ t i c k   =   0 ;  
 / / - - -  
       d o u b l e   p r e v _ e r   =   D B L _ M A X ;  
       d a t e t i m e   b a r _ t i m e   =   0 ;  
       b o o l   s t o p   =   I s S t o p p e d ( ) ;  
       C A r r a y D o u b l e   * l o s s   =   n e w   C A r r a y D o u b l e ( ) ;  
       M q l D a t e T i m e   s T i m e ;  
 / / - - -  
       i n t   b a r s   =   C o p y R a t e s ( S y m b . N a m e ( ) ,   T i m e F r a m e ,   s t _ t i m e ,   T i m e C u r r e n t ( ) ,   R a t e s ) ;  
       p r e v _ e r   =   d E r r o r ;  
 / / - - -  
       i f ( ! R S I . B u f f e r R e s i z e ( b a r s )   | |   ! C C I . B u f f e r R e s i z e ( b a r s )   | |   ! A T R . B u f f e r R e s i z e ( b a r s )   | |   ! M A C D . B u f f e r R e s i z e ( b a r s ) )  
           {  
             E x p e r t R e m o v e ( ) ;  
             r e t u r n ;  
           }  
       i f ( ! A r r a y S e t A s S e r i e s ( R a t e s ,   t r u e ) )  
           {  
             E x p e r t R e m o v e ( ) ;  
             r e t u r n ;  
           }  
       R S I . R e f r e s h ( O B J _ A L L _ P E R I O D S ) ;  
       C C I . R e f r e s h ( O B J _ A L L _ P E R I O D S ) ;  
       A T R . R e f r e s h ( O B J _ A L L _ P E R I O D S ) ;  
       M A C D . R e f r e s h ( O B J _ A L L _ P E R I O D S ) ;  
 / / - - -  
       i n t   t o t a l   =   ( i n t ) ( b a r s   -   M a t h M a x ( H i s t o r y B a r s ,   0 ) ) ;  
       C B u f f e r F l o a t *   c h e c k _ d a t a   =   n e w   C B u f f e r F l o a t ( ) ;  
       i f ( ! c h e c k _ d a t a )  
             r e t u r n ;  
       u i n t   c h e c k _ c o u n t   =   H i s t o r y B a r s   *   1 2 ;  
       i f ( ! c h e c k _ d a t a . B u f f e r I n i t ( c h e c k _ c o u n t ,   0 ) )  
             r e t u r n ;  
       d o  
           {  
             / / - - -  
             s t o p   =   I s S t o p p e d ( ) ;  
             p r e v _ e r   =   d E r r o r ;  
             f o r ( i n t   i t   =   t o t a l   -   1 ;   i t   > =   0   & &   ! s t o p ;   i t - - )  
                 {  
                   i n t   i   =   i t ; / / ( i n t ) ( ( M a t h R a n d ( )   *   M a t h R a n d ( )   /   M a t h P o w ( 3 2 7 6 7 ,   2 ) )   *   ( t o t a l ) ) ;  
                   i f ( ( G e t T i c k C o u n t 6 4 ( )   -   l a s t _ t i c k )   > =   2 5 0 )  
                       {  
                         c o m   =   S t r i n g F o r m a t ( " S t u d y   - >   E r a   % d   - >   % . 6 f \ n   % d   o f   % d   - >   % . 2 f % %   \ n E r r o r   % . 5 f " ,   c o u n t ,   p r e v _ e r ,   b a r s   -   i t   +   1 ,   b a r s ,   ( d o u b l e ) ( b a r s   -   i t   +   1 . 0 )   /   b a r s   *   1 0 0 ,   N e t . g e t R e c e n t A v e r a g e E r r o r ( ) ) ;  
                         C o m m e n t ( c o m ) ;  
                         l a s t _ t i c k   =   G e t T i c k C o u n t 6 4 ( ) ;  
                       }  
                   T e m p D a t a . C l e a r ( ) ;  
                   i n t   r   =   i   +   ( i n t ) 5 ;  
                   i f ( r   >   b a r s )  
                         c o n t i n u e ;  
                   / / - - -  
                   f o r ( i n t   b   =   0 ;   b   <   ( i n t ) 5 ;   b + + )  
                       {  
                         i n t   b a r _ t   =   r   -   b ;  
                         d o u b l e   o p e n   =   R a t e s [ b a r _ t ] . o p e n ;  
                         T i m e T o S t r u c t ( R a t e s [ b a r _ t ] . t i m e ,   s T i m e ) ;  
                         f l o a t   r s i   =   ( f l o a t ) R S I . M a i n ( b a r _ t ) ;  
                         f l o a t   c c i   =   ( f l o a t ) C C I . M a i n ( b a r _ t ) ;  
                         f l o a t   a t r   =   ( f l o a t ) A T R . M a i n ( b a r _ t ) ;  
                         f l o a t   m a c d   =   ( f l o a t ) M A C D . M a i n ( b a r _ t ) ;  
                         f l o a t   s i g n   =   ( f l o a t ) M A C D . S i g n a l ( b a r _ t ) ;  
                         i f ( r s i   = =   E M P T Y _ V A L U E   | |   c c i   = =   E M P T Y _ V A L U E   | |   a t r   = =   E M P T Y _ V A L U E   | |   m a c d   = =   E M P T Y _ V A L U E   | |   s i g n   = =   E M P T Y _ V A L U E )  
                               c o n t i n u e ;  
                         / / - - -  
                         i f ( ! T e m p D a t a . A d d ( ( f l o a t ) ( R a t e s [ b a r _ t ] . c l o s e   -   o p e n ) )   | |   ! T e m p D a t a . A d d ( ( f l o a t ) ( R a t e s [ b a r _ t ] . h i g h   -   o p e n ) )   | |   ! T e m p D a t a . A d d ( ( f l o a t ) ( R a t e s [ b a r _ t ] . l o w   -   o p e n ) )   | |   ! T e m p D a t a . A d d ( ( f l o a t ) ( R a t e s [ b a r _ t ] . t i c k _ v o l u m e   /   1 0 0 0 . 0 ) )   | |  
                               ! T e m p D a t a . A d d ( s T i m e . h o u r )   | |   ! T e m p D a t a . A d d ( s T i m e . d a y _ o f _ w e e k )   | |   ! T e m p D a t a . A d d ( s T i m e . m o n )   | |  
                               ! T e m p D a t a . A d d ( r s i )   | |   ! T e m p D a t a . A d d ( c c i )   | |   ! T e m p D a t a . A d d ( a t r )   | |   ! T e m p D a t a . A d d ( m a c d )   | |   ! T e m p D a t a . A d d ( s i g n ) )  
                               b r e a k ;  
                       }  
                   i f ( T e m p D a t a . T o t a l ( )   <   ( i n t ) 5   *   1 2 )  
                         c o n t i n u e ;  
                   N e t . f e e d F o r w a r d ( T e m p D a t a ,   1 2 ,   t r u e ) ;  
                   T e m p D a t a . C l e a r ( ) ;  
                   i f ( ! N e t . G e t L a y e r O u t p u t ( 1 ,   T e m p D a t a ) )  
                         b r e a k ;  
                   u i n t   c h e c k _ t o t a l   =   c h e c k _ d a t a . T o t a l ( ) ;  
                   i f ( c h e c k _ t o t a l   > =   c h e c k _ c o u n t )  
                       {  
                         i f ( ! c h e c k _ d a t a . D e l e t e R a n g e ( 0 ,   c h e c k _ t o t a l   -   c h e c k _ c o u n t   +   1 2 ) )  
                               r e t u r n ;  
                       }  
                   f o r ( i n t   t   =   T e m p D a t a . T o t a l ( )   -   1 2   -   1 ;   t   <   T e m p D a t a . T o t a l ( ) ;   t + + )  
                       {  
                         i f ( ! c h e c k _ d a t a . A d d ( T e m p D a t a . A t ( t ) ) )  
                               r e t u r n ;  
                       }  
                   i f ( ( t o t a l - i t ) > ( i n t ) H i s t o r y B a r s )  
                         N e t . b a c k P r o p ( c h e c k _ d a t a ) ;  
                   s t o p   =   I s S t o p p e d ( ) ;  
                 }  
             i f ( ! s t o p )  
                 {  
                   d E r r o r   =   N e t . g e t R e c e n t A v e r a g e E r r o r ( ) ;  
                   N e t . S a v e ( F i l e N a m e   +   " . n n w " ,   d E r r o r ,   0 ,   0 ,   d t S t u d i e d ,   f a l s e ) ;  
                   p r i n t f ( " E r a   % d   - >   e r r o r   % . 5 f   % % " ,   c o u n t ,   d E r r o r ) ;  
                   l o s s . A d d ( d E r r o r ) ;  
                   c o u n t + + ;  
                 }  
           }  
       w h i l e ( ! ( d E r r o r   <   0 . 0 1   & &   ( p r e v _ e r   -   d E r r o r )   <   0 . 0 1 )   & &   ! s t o p ) ;  
 / / - - -  
       d e l e t e   c h e c k _ d a t a ;  
       C o m m e n t ( " W r i t e   d i n a m i c   o f   e r r o r " ) ;  
       i n t   h a n d l e   =   F i l e O p e n ( " a e _ l o s s . c s v " ,   F I L E _ W R I T E   |   F I L E _ C S V   |   F I L E _ A N S I ,   " , " ,   C P _ U T F 8 ) ;  
       i f ( h a n d l e   = =   I N V A L I D _ H A N D L E )  
           {  
             P r i n t F o r m a t ( " E r r o r   o f   o p e n   l o s s   f i l e :   % d " ,   G e t L a s t E r r o r ( ) ) ;  
             d e l e t e   l o s s ;  
             r e t u r n ;  
           }  
       f o r ( i n t   i   =   0 ;   i   <   l o s s . T o t a l ( ) ;   i + + )  
             i f ( F i l e W r i t e ( h a n d l e ,   l o s s . A t ( i ) )   < =   0 )  
                   b r e a k ;  
       F i l e C l o s e ( h a n d l e ) ;  
       P r i n t F o r m a t ( " T h e   d y n a m i c s   o f   t h e   e r r o r   c h a n g e   i s   s a v e d   t o   a   f i l e   % s \ \ % s " ,  
                               T e r m i n a l I n f o S t r i n g ( T E R M I N A L _ D A T A _ P A T H ) ,   " a e _ l o s s . c s v " ) ;  
       d e l e t e   l o s s ;  
       C o m m e n t ( " " ) ;  
       E x p e r t R e m o v e ( ) ;  
     }  
 / / + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +  
 