*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 24.07.2019 at 15:34:48
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZDLV_WF.........................................*
DATA:  BEGIN OF STATUS_ZDLV_WF                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDLV_WF                       .
CONTROLS: TCTRL_ZDLV_WF
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZDLV_WF                       .
TABLES: ZDLV_WF                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
