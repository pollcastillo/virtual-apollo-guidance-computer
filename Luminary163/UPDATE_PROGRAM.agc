### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    UPDATE_PROGRAM.agc
## Purpose:     A section of Luminary revision 163.
##              It is part of the reconstructed source code for the first
##              (unflown) release of the flight software for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 14.
##              The code has been recreated from a reconstructed copy of
##              Luminary 173, as well as Luminary memos 157 amd 158.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 163 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 1374-1384
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Warning:     THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
##              AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
##              LUMINARY 163.
## Mod history: 2019-08-21 MAS  Created from Luminary 173.

## Page 1374
# PROGRAM NAME:   P27
# WRITTEN BY:     KILROY/ DE WOLF

# MOD NO:         6
# MOD BY:         KILROY
# DATE:           01DEC67

# LOG SECTION:    UPDATE PROGRAM.

# FUNCT. DESCR:   P27 (THE UPDATE PROGRAM) PROCESSES COMMANDS AND DATA
#                     INSERTIONS REQUESTED BY THE GROUND VIA UPLINK.
#                     THE P27 PROGRAM WILL ACCEPT UPDATES
#                     ONLY DURING P00 FOR THE LM, AND ONLY DURING P00,
#                 P02, AND FRESH START FOR THE CSM

# CALLING SEQ:    PROGRAM IS INITIATED BY UPLINK ENTRY OF VERBS 70, 71, 72 AND 73.

# SUBROUTINES:    TESTXACT, NEWMODEX, NEWMODEX +3, GOXDSPF, BANKCALL, FINDVAC, INTPRET, INTSTALL, TPAGREE,
#                 INTWAKEU, ENDEXT, POSTJUMP, FALTON, NEWPHASE, PHASCHNG

# NORMAL EXIT:    TC ENDEXT

# ALARM/ABORT:    TC FALTON FOLLOWED BY TC ENDEXT

# RESTARTS:       P27 IS RESTART PROTECTED IN TWO WAYS...
#                 1. PRIOR TO VERIFLAG INVERSION(WHICH IS CAUSED BY THE GROUND/ASTRONAUT'S VERIFICATION OF UPDATE
#                    DATA BY SENDING A V33E WHEN V21N02 IS FLASHING)---
#                    NO PROTECTION EXCEPT PRE-P27 MODE IS RESTORED, COAST + ALIGN DOWNLIST IS SELECTED AND UPLINK
#                    ACTIVITY LIGHT IS TURNED OFF.(JUST AS IF A V34E WAS SENT DURING P27 DATA LOADS).
#                    V70,V71,V72 OR V73 WILL HAVE TO BE COMPLETELY RESENT BY USER.
#                 2. AFTER VERIFLAG INVERSION(WHEN UPDATE OF THE SPECIFIED ERASABLES IS BEING PERFORMED)---
#                    PROTECTED AGAINST RESTARTS.

# DEBRIS:         UPBUFF   (20D)  TEMP STORAGE FOR ADDRESSES AND CONTENTS.
#                 UPVERB   (1)    VERB NUMBER MINUS 70D (E.G. FOR V72, UPVERB = 72D - 70D = 2)
#                 UPOLDMOD (1)    FOR MAJOR MODE INTERRUPTED BY P27.
#                 COMPNUMB (1)    TOTAL NUMBER OF COMPONENTS TO BE TRANSMITTED.
#                 UPCOUNT  (1)    ACTUAL NUMBER OF COMPONENTS RECEIVED.
#                 UPTEMP   (1)    SCRATCH, BUT USUALLY CONTAINS COMPONENT NUMBER TO BE CHANGED DURING VERIFY CYCLE
#

# INPUT:

#       ENTRY:      DESCRIPTION

#  V70EXXXXXEXXXXXE (LIFTOFF TIME INCREMENT) DOUBLE PRECISION OCTAL TIME INCREMENT, XXXXX XXXXX,
#                   IS ADDED TO TEPHEM, SUBTRACTED FROM AGC CLOCK(TIME2,TIME1), SUBTRACTED FROM CSM STATE
#                   VECTOR TIME(TETCSM) AND SUBTRACTED FROM LEM STATE VECTOR TIME(TETLEM).
#                   THE DP OCTAL TIME INCREMENT IS SCALED AT 2(28).
## Page 1375
#  V71EIIEAAAAE     (CONTIGUOUS BLOCK UPDATE) II-2 OCTAL COMPONENTS,XXXXX,
#  XXXXXE           ARE LOADED INTO ERASABLE STARTING AT ECADR, AAAA.
# XXXXXE            IT IS .GE. 3 .AND. .LE. 20D.,
#                   AND (AAAA + II - 3) DOES NOT PRODUCE AN ADDRESS IN THE
# 9 NEXT BANK
#   .               SCALING IS SAME AS INTERNAL REGISTERS.

#  V72EIIE          (SCATTER UPDATE) (II-1)/2 OCTAL COMPONENTS,XXXXX, ARE
#  AAAAEXXXXXE      LOADED INTO ERASABLE LOCATIONS, AAAA.
#  AAAAEXXXXXE      II IS .GE. 3 .AND. .LE. 19D, AND MUST BE ODD.
#   .               SCALING IS SAME AS INTERNAL REGISTERS.

#  V73EXXXXXEXXXXXE (OCTAL CLOCK INCREMENT) DOUBLE PRECISION OCTAL TIME
#                   INCREMENT XXXXX XXXXX, IS ADDED TO THE AGC CLOCK, IN
#                   CENTISECONDS SCALED AT (2)28.
#                   THIS LOAD IS THE OCTAL EQUIVALENT OF V55.


# OUTPUT:         IN ADDITION TO THE ABOVE REGISTER LOADS, ALL UPDATES
#                 COMPLEMENT BIT3 OF FLAGWORD7.


# ADDITIONAL NOTES: VERB 71, JUST DEFINED ABOVE WILL BE USED TO PERFORM BUT NOT LIMITED TO THE FOLLOWING UPDATES--

#                 1. CSM/LM STATE VECTOR UPDATE
#                 2. REFSMMAT UPDATE


#          THE FOLLOWING COMMENTS DELINEATE EACH SPECIAL UPDATE----

# 1. CSM/LM STATE VECTOR UPDATE(ALL DATA ENTRIES IN OCTAL)

# ENTRIES:        DATA DEFINITION:                                        SCALE FACTORS:
# V71E            CONTIGUOUS BLOCK UPDATE VERB
#    21E          NUMBER OF COMPONENTS FOR STATE VECTOR UPDATE
#  AAAAE          ECADR OF 'UPSVFLAG'
# XXXXXE          STATE VECTOR IDENTIFIER: 00001 FOR CSM, 77776 FOR LEM - EARTH SPHERE OF INFLUENCE SCALING
#                                          00002 FOR CSM, 77775 FOR LEM - LUNAR SPHERE OF INFLUENCE SCALING
# XXXXXEXXXXXE    X POSITION
# XXXXXEXXXXXE    Y POSITION
# XXXXXEXXXXXE    Z POSITION
# XXXXXEXXXXXE    X VELOCITY
# XXXXXEXXXXXE    Y VELOCITY
# XXXXXEXXXXXE    Z VELOCITY
# XXXXXEXXXXXE    TIME FROM AGC CLOCK ZERO
# V33E            VERB 33 TO SIGNAL THAT THE STATE VECTOR IS READY TO BE STORED.


# 2. REFSMMAT(ALL DATA ENTRIES IN OCTAL)
# ENTRIES:        DATA DEFINITIONS:                                       SCALE FACTORS:
## Page 1376
# V71E            CONTIGUOUS BLOCK UPDATE VERB
#    24E          NUMBER OF COMPONENTS FOR REFSMMAT UPDATE
#  AAAAE          ECADR OF 'REFSMMAT'
# XXXXXEXXXXXE    ROW 1 COLUMN 1                                          2(-1)
# XXXXXEXXXXXE    ROW 1 COLUMN 2                                          2(-1)
# XXXXXEXXXXXE    ROW 1 COLUMN 3                                          2(-1)
# XXXXXEXXXXXE    ROW 2 COLUMN 1                                          2(-1)
# XXXXXEXXXXXE    ROW 2 COLUMN 2                                          2(-1)
# XXXXXEXXXXXE    ROW 2 COLUMN 3                                          2(-1)
# XXXXXEXXXXXE    ROW 3 COLUMN 1                                          2(-1)
# XXXXXEXXXXXE    ROW 3 COLUMN 2                                          2(-1)
# XXXXXEXXXXXE    ROW 3 COLUMN 3                                          2(-1)
# V33E            VERB 33 TO SIGNAL THAT REFSMMAT IS READY TO BE STORED.

                BANK    07
                SETLOC  EXTVERBS
                BANK

                EBANK=  TEPHEM

                COUNT*  $$/P27
V70UPDAT        CAF     UP70            # COMES HERE ON V70E
                TCF     V73UPDAT +1


V71UPDAT        CAF     UP71            # COMES HERE ON V71E
                TCF     V73UPDAT +1


V72UPDAT        CAF     UP72            # COMES HERE ON V72E
                TCF     V73UPDAT +1


V73UPDAT        CAF     UP73            # COMES HERE ON V73E

 +1             TS      UPVERBSV        # SAVE UPVERB UNTIL IT'S OK TO ENTER P27

                TC      TESTXACT        # GRAB DISPLAY IF AVAILABLE, OTHERWISE
                                        # TURN*OPERATOR ERROR* ON AND TERMINATEJOB

                TC      POSTJUMP        # LEAVE EXTENDED VERB BANK AND
                CADR    UPPART2         # GO TO UPDATE PROGRAM(P27) BANK.


UP70            EQUALS  ZERO
UP71            EQUALS  ONE
UP72            EQUALS  TWO
UP73            EQUALS  THREE

## Page 1377
                BANK    04
                SETLOC  UPDATE2
                BANK

                COUNT*  $$/P27

UPPART2         EQUALS                  # UPDATE PROGRAM - PART 2

                CA      MODREG          # IS UPDATE ALLOWED AT THIS TIME?
                EXTEND                  # IS MODREG +0 (POOH) OR -0 (FRESH START)?
                BZF     UPDATOK

UPERROR         TC      UPERROUT +2     # TURN ON OPERATOR ERROR LIGHT AND EXIT

UPDATOK         TS      UPOLDMOD

                CAE     UPVERBSV        # SET UPVERB TO TELL P27 WHICH EXTENDED
                TS      UPVERB          #   VERB CALLED IT

                CAF     ONE
                TS      UPCOUNT

                TC      PHASCHNG        # SET RESTART GROUP 6 TO RESTORE OLD MODE
                OCT     07026           # AND DOWNLIST AND EXIT IF RESTART OCCURS.
                OCT     30000           # PRIORITY SAME AS CHRPRIO
                EBANK=  UPBUFF
                2CADR   UPOUT +1


                CAF     ONE
                TS      DNLSTCOD        # DOWNLIST

                TC      NEWMODEX        # SET MAJOR MODE = 27
                DEC     27

                INDEX   UPVERB          # BRANCH DEPENDING ON WHETHER THE UPDATE
                TCF     +1              # VERB REQUIRES A FIXED OR VARIABLE NUMBER
                TCF     +3              # V70 FIXED.               (OF COMPONENTS.
                TCF     OHWELL1         # V71 VARIABLE - GO GET NO. OF COMPONENTS
                TCF     OHWELL1         # V72 VARIABLE - GO GET NO. OF COMPONENTS
                CA      TWO             # V73 (AND V70) FIXED
                TS      COMPNUMB        # SET NUMBER OF COMPONENTS TO 2.
                TCF     OHWELL2         # GO GET THE TWO UPDATE COMPONENTS

OHWELL1         CAF     ADUPBUFF        # * REQUEST USER TO SEND NUMBER  *
                TS      MPAC +2         # * OF COMPONENTS PARAMETER(II). *
 +2             CAF     UPLOADNV        # (CK4V32 RETURNS HERE IF V32 ENCOUNTERED)
                TC      BANKCALL        # DISPLAY A FLASHING V21N01
                CADR    GOXDSPF         # TO REQUEST II.
                TCF     UPOUT4          # V34 TERMINATE UPDATE (P27) RETURN
## Page 1378
                TCF     OHWELL1 +2
                TC      CK4V32          # DATA OR V32 RETURN
                CS      BIT2
                AD      UPBUFF          # IS II(NUMBER OF COMPONENTS PARAMETER)
                EXTEND                  # .GE. 3 AND .LE. 20D.
                BZMF    OHWELL1 +2
                CS      UPBUFF
                AD      UP21
                EXTEND
                BZMF    OHWELL1 +2
                CAE     UPBUFF
                TS      COMPNUMB        # SAVE II IN COMPNUMB


#          UPBUFF LOADING SEQUENCE

                INCR    UPCOUNT         # INCREMENT COUNT OF COMPONENTS RECEIVED.
OHWELL2         CAF     ADUPBFM1        # CALCULATE LOCATION(ECADR) IN UPBUFF
                AD      UPCOUNT         # WHERE NEXT COMPONENT SHOULD BE STORED.
 +2             TS      MPAC +2         # PLACE ECADR INTO R3.
 +3             CAF     UPLOADNV        # (CK4V32 RETURNS HERE IF V32 ENCOUNTERED)
                TC      BANKCALL        # DISPLAY A FLASHING V21N01
                CADR    GOXDSPF         # TO REQUEST DATA.
                TCF     UPOUT4          # V34 TERMINATE UPDATE(P27) RETURN.
                TCF     OHWELL2 +3      # V33 PROCEED RETURN
                TC      CK4V32          # DATA OR V32 RETURN
                CS      UPCOUNT         # HAVE WE FINISHED RECEIVING ALL
                AD      COMPNUMB        # THE DATA WE EXPECTED.
                EXTEND
                BZMF    UPVERIFY        # YES- GO TO VERIFICATION SEQUENCE
                TCF     OHWELL2 -1      # NO- REQUEST ADDITIONAL DATA.


#          VERIFY SEQUENCE

UPVERIFY        CAF     ADUPTEMP        # PLACE ECADR WHERE COMPONENT NO. INDEX
                TS      MPAC +2         # IS TO BE STORED INTO R3.
                CAF     UPVRFYNV        # (CK4V32 RETURNS HERE IF V32 ENCOUNTERED)
                TC      BANKCALL        # DISPLAY A FLASHING V21N02 TO REQUEST
                CADR    GOXDSPF         # DATA CORRECTION OR VERIFICATION.
                TCF     UPOUT4          # V34 TERMINATE UPDATE(P27) RETURN
                TCF     UPSTORE         # V33 DATA SENT IS GOOD. GO STORE IT.
                TC      CK4V32          # COMPONENT NO. INDEX OR V32 RETURN
                CA      UPTEMP          # DOES THE COMPONENT NO. INDEX JUST SENT
                EXTEND                  # SPECIFY A LEGAL COMPONENT NUMBER?
                BZMF    UPVERIFY        # NO, IT IS NOT POSITIVE NONZERO
                CS      UPTEMP
                AD      COMPNUMB
                AD      BIT1
                EXTEND
## Page 1379
                BZMF    UPVERIFY        # NO
                CAF     ADUPBFM1        # YES- BASED ON THE COMPONENT NO. INDEX
                AD      UPTEMP          # CALCULATE THE ECADR OF LOCATION IN
                TCF     OHWELL2 +2      # UPBUFF WHICH USER WANTS TO CHANGE.

UPOUT4          EQUALS  UPOUT +1        # COMES HERE ON V34 TO TERMINATE UPDATE


#          CHECK FOR VERB 32 SEQUENCE

CK4V32          CS      MPAC            # ON DATA RETURN FROM 'GOXDSPF'
                MASK    BIT6            # ON DATA RETURN FROM "GOXDSP"& THE CON-
                CCS     A               # TENTS OF MPAC = VERB.  SO TEST FOR V32.
                TC      Q               # IT'S NOT A V32, IT'S DATA.  PROCEED.
                INDEX   Q
                TC      0 -6            # V32 ENCOUNTERED - GO BACK AND GET DATA

ADUPTEMP        ADRES   UPTEMP          # ADDRESS OF TEMP STORAGE FOR CORRECTIONS
ADUPBUFF        ADRES   UPBUFF          # ADDRESS OF UPDATE DATA STORAGE BUFFER
UPLOADNV        VN      2101            # VERB 21 NOUN 01
UPVRFYNV        VN      2102            # VERB 21 NOUN 02
UP21            =       MD1             # DEC 21 = MAX NO OF COMPONENTS +1
UPDTPHAS        EQUALS  FIVE

#          PRE-STORE AND FAN TO APPROPRIATE BRANCH SEQUENCE

UPSTORE         EQUALS                  # GROUND HAS VERIFIED UPDATE. STORE DATA.

                INHINT

                CAE     FLAGWRD7        # INVERT VERIFLAG(BIT3 OF FLAGWRD7) TO
                XCH     L               # INDICATE TO THE GROUND(VIA DOWNLINK)
                CAF     VERIFBIT        # THAT THE V33 (WHICH THE GROUND SENT TO
                EXTEND                  # VERIFY THE UPDATE) HAS BEEN SUCCESSFULLY
                RXOR    LCHAN           # RECEIVED BY THE UPDATE PROGRAM
                TS      FLAGWRD7

                TC      PHASCHNG        # SET RESTART GROUP 6 TO REDO THE UPDATE
                OCT     04026           # DATA STORE IF A RESTART OCCURS.
                INHINT                  # (BECAUSE PHASCHNG DID A RELINT)

                CS      TWO             # GO TO UPFNDVAC IF INSTALL IS REQUIRED,
                AD      UPVERB          # THAT IS, IF IT'S A V70 - V72.
                EXTEND                  # GO TO UPEND73 IF IT'S A V73.
                BZMF    UPFNDVAC

#          VERB 73 BRANCH

UPEND73         EXTEND                  # V73-PERFORM DP OCTAL AGC CLOCK INCREMENT
                DCA     UPBUFF
## Page 1380
                DXCH    UPBUFF +8D
                TC      TIMEDIDL
                TC      FALTON          # ERROR- TURN ON *OPERATOR ERROR* LIGHT
                TC      UPOUT +1        # GO TO COMMON UPDATE PROGRAM EXIT

UPFNDVAC        CAF     CHRPRIO         # (USE EXTENDED VERB PRIORITY)
                TC      FINDVAC         # GET VAC AREA FOR 'CALL INTSTALL'
                EBANK=  TEPHEM
                2CADR   UPJOB           # (NOTE: THIS WILL ALSO SET EBANK FOR
                
                TC      ENDOFJOB        # 'TEPHEM' UPDATE BY V70)

UPJOB           TC      INTPRET         # THIS COULD BE A STATE VECTOR UPDATE--SO
                CALL                    # WAIT(PUT JOB TO SLEEP) IF ORBIT INT(OI)
                        INTSTALL        # IS IN PROGRESS--OR--GRAB OI AND RETURN
                                        # TO UPWAKE IF OI IS NOT IN PROGRESS.

UPWAKE          EXIT

                TC      PHASCHNG        # RESTART PROTECT(GROUP 6)
                OCT     04026

                TC      UPFLAG          # SET INTEGRATION RESTART BIT
                ADRES   REINTFLG
                INHINT
UPPART3         EQUALS

                INDEX   UPVERB          # BRANCH TO THE APPROPRIATE UPDATE VERB
                TCF     +1              # ROUTINE TO ACTUALLY PERFORM THE UPDATE
                TCF     UPEND70         # V70
                TCF     UPEND71         # V71
                TCF     UPEND72         # V72


#          ROUTINE TO INCREMENT CLOCK(TIME2,TIME1) WITH CONTENTS OF DP WORD AT UPBUFF.

TIMEDIDL        EXTEND
                QXCH    UPTEMP          # SAVE Q FOR RETURN
                CAF     ZERO            # ZERO AND SAVE TIME2,TIME1
                ZL
                DXCH    TIME2
                DXCH    UPBUFF +18D     # STORE IN CASE OF OVERFLOW

                CAF     UPDTPHAS        # DO
                TS      L               # A
                COM                     # QUICK
                DXCH    -PHASE6         # PHASCHNG

TIMEDIDR        INHINT
## Page 1381
                CAF     ZERO
                ZL                      # PICK UP INCREMENTER(AND ZERO
                TS      MPAC +2         # IT IN CASE OF RESTARTS) AND
                DXCH    UPBUFF +8D      # STORE IT
                DXCH    MPAC            # INTO MPAC FOR TPAGREE.

                EXTEND
                DCA     UPBUFF +18D
                DAS     MPAC            # FORM SUM IN MPAC
                EXTEND
                BZF     DELTAOK         # TEST FOR OVERFLOW
                CAF     ZERO
                DXCH    UPBUFF +18D     # OVERFLOW, RESTORE OLD VALUE OF CLOCK
                DAS     TIME2           # AND TURN ON OPERATOR ERROR

                TC      PHASCHNG        # RESTART PROTECT(GROUP 6)
                OCT     04026

                TC      UPTEMP          # GO TO ERROR EXIT

DELTAOK         TC      TPAGREE         # FORCE SIGN AGREEMENT
                DXCH    MPAC
                DAS     TIME2           # INCREMENT TIME2,TIME1

                TC      PHASCHNG        # RESTART PROTECT(GROUP 6)
                OCT     04026

                INHINT
                INDEX   UPTEMP          # (CODED THIS WAY FOR RESTART PROTECTION)
                TC      1               # NORMAL RETURN
#          VERB 71 BRANCH

UPEND71         CAE     UPBUFF +1       # SET EBANK
                TS      EBANK           #    AND
                MASK    LOW8            # CALCULATE
                TS      UPTEMP          # S-REG VALUE OF RECEIVING AREA

                AD      NEG3            # IN THE PROCESS OF
                AD      COMPNUMB        # PERFORMING
                EXTEND                  # THIS UPDATE
                BZF     STORLP71        # WILL WE
                MASK    BIT9            # OVERFLOW
                CCS     A               # INTO THE NEXT EBANK....
                TCF     UPERROUT        # YES

                CA      NEG3            # NO- CALCULATE NUMBER OF
                AD      COMPNUMB        # WORDS TO BE STORED MINUS ONE
STORLP71        TS      MPAC            # SAVE NO. OF WORDS REMAINING MINUS ONE
                INDEX   A               # TAKE NEXT UPDATE WORD FROM
                CA      UPBUFF +2       # UPBUFF AND
## Page 1382
                TS      L               # SAVE IT IN L
                CA      MPAC            # CALCULATE NEXT
                AD      UPTEMP          # RECEIVING ADDRESS
                INDEX   A
                EBANK=  1400
                LXCH    1400            # UPDATE THE REGISTER  BY CONTENTS OF L
                EBANK=  TEPHEM
                CCS     MPAC            # ARE THERE ANY WORDS LEFT TO BE STORED
                TCF     STORLP71        # YES
                TCF     UPOUT           # NO- THEN EXIT UPDATE PROGRAM
ADUPBFM1        ADRES   UPBUFF -1       # SAME AS ADUPBUFF BUT LESS 1 (DON'T MOVE)
                TCF     UPOUT           # NO- EXIT UPDATE(HERE WHEN COMPNUMB = 3)


#          VERB 72 BRANCH

UPEND72         CAF     BIT1            # HAVE AN ODD NO. OF COMPONENTS
                MASK    COMPNUMB        # BEEN SENT FOR A V72 UPDATE...
                CCS     A
                TCF     +2              # YES
                TCF     UPERROUT        # ERROR- SHOULD BE ODD NO. OF COMPONENTS
                CS      BIT2
                AD      COMPNUMB
LDLOOP72        TS      MPAC            # NOW PERFORM THE UPDATE
                INDEX   A
                CAE     UPBUFF +1       # PICK UP NEXT UPDATE WORD
                LXCH    A
                CCS     MPAC            # SET POINTER TO ECADR(MUST BE CCS)
                TS      MPAC
                INDEX   A
                CAE     UPBUFF +1       # PICK UP NEXT ECADR OF REG TO BE UPDATED
                TS      EBANK           # SET EBANK
                MASK    LOW8            # ISOLATE RELATIVE ADDRESS
                INDEX   A
                EBANK=  1400
                LXCH    1400            # UPDATE THE REGISTER BY CONTENTS OF L
                EBANK=  TEPHEM
                CCS     MPAC            # ARE WE THROUGH THE V72 UPDATE...
                TCF     LDLOOP72        # NO


#          NORMAL FINISH OF P27

UPOUT           EQUALS
                TC      INTWAKEU        # RELEASE  GRAB  OF ORBITAL INTEGRATION
 +1             CAE     UPOLDMOD        # RESTORE PRIOR P27 MODE
                TC      NEWMODEX +3
                CAF     ZERO
                TS      DNLSTCOD
                TC      UPACTOFF        # TURN OFF 'UPLINK ACTIVITY' LIGHT
## Page 1383
                EXTEND                  # KILL GROUP 6.
                DCA     NEG0
                DXCH    -PHASE6

                TC      ENDEXT          # EXTENDED VERB EXIT


#          VERB 70 BRANCH

UPEND70         EXTEND                  # V70 DOES THE FOLLOWING WITH DP DELTA
                DCS     UPBUFF          # TIME IN UPBUFF
                DXCH    UPBUFF +8D
                TC      TIMEDIDL        # DECREMENT AGC CLOCK

                TC      UPERROUT        # ERROR WHILE DECREMENTING CLOCK -- EXIT

                EBANK=  TEPHEM
                EXTEND
                DCS     UPBUFF          # COPY DECREMENTERS FOR
                DXCH    UPBUFF +10D     # RESTART PROTECTION
                EXTEND
                DCS     UPBUFF
                DXCH    UPBUFF +12D

                TC      PHASCHNG        # RESTART PROTECT(GROUP 6)
                OCT     04026

                CAF     ZERO
                ZL
                DXCH    UPBUFF +10D     # DECREMENT CSM STATE VECTOR TIME
                DAS     TETCSM

                CAF     ZERO
                ZL
                DXCH    UPBUFF +12D     # DECREMENT LEM STATE VECTOR TIME
                DAS     TETLEM

                CAF     ZERO
                ZL
                DXCH    UPBUFF
                DAS     TEPHEM +1       # INCREMENT TP TEPHEM
                ADS     TEPHEM

                TC      PHASCHNG        # RESTART PROTECT(GROUP 6)
                OCT     04026

                EBANK=  UPBUFF

                TC      UPOUT           # GO TO STANDARD UPDATE PROGRAM EXIT

## Page 1384
#          ERROR SEQUENCE

UPERROUT        TC      FALTON          # TURN ON *OPERATOR ERROR* LIGHT
                TCF     UPOUT           # GO TO COMMON UPDATE PROGRAM EXIT

 +2             TC      FALTON          # TURN ON 'OPERATOR ERROR' LIGHT
                TC      UPACTOFF        # TURN OFF'UPLINK ACTIVITY'LIGHT
                TC      ENDEXT          # EXTENDED VERB EXIT
                                        # (THE PURPOSE OF UPERROUT +2 EXIT IS
                                        # TO PROVIDE AN ERROR EXIT WHICH DOES NOT
                                        # RESET ANY RESTART GROUPS)
#


#          :UPACTOFF: IS A ROUTINE TO TURN OFF UPLINK ACTIVITY LIGHT ON ALL EXITS FROM UPDATE PROGRAM(P27).

UPACTOFF        CS      BIT3
                EXTEND                  # TURN OFF UPLINK ACTIVITY LIGHT
                WAND    DSALMOUT        # (BIT 3 OF CHANNEL 11)
                TC      Q