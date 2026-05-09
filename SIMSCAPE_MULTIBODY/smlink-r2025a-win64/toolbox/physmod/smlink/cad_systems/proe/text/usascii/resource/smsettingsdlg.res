!  Copyright 2005-2015 The MathWorks, Inc.
!
(Dialog smsettingsdlg
     (Components
         (PushButton                     OK)
         (PushButton                     Cancel)
         (SubLayout                      TolLayout)
         (SubLayout                      CSOptLayout)
		 (SubLayout                      CADOptLayout)                                                                                             
     )
    (Resources
         (OK.Label                       "OK")
         (OK.TopOffset                   8)
         (OK.BottomOffset                8)
         (OK.LeftOffset                  4)
         (OK.RightOffset                 4)
         (Cancel.Label                   "Cancel")
         (Cancel.TopOffset               8)
         (Cancel.BottomOffset            8)
         (Cancel.LeftOffset              4)
         (Cancel.RightOffset             4)
         (.Label                         "Simscape Multibody Link Settings")
         (.Layout
	       (Grid (Rows 1 1 1 1) (Cols 1)
	            TolLayout
                CSOptLayout
				CADOptLayout
	            (Grid (Rows 1) (Cols 1 1)                                                           
                    OK
                    Cancel
                )
            )
         )
     )
 )
 
 (Layout TolLayout
     (Components
         (InputPanel                     LTolPanel)
         (Label                          LTolLabel)
         (InputPanel                     ATolPanel)
         (Label                          ATolLabel)
         (InputPanel                     RTolPanel)
         (Label                          RTolLabel)
     )
    (Resources
         (LTolPanel.TopOffset            8)
         (LTolPanel.BottomOffset         4)
         (LTolPanel.LeftOffset           4)
         (LTolPanel.RightOffset          4)
         (LTolPanel.InputType            3)
         (LTolPanel.MinDouble            0.0)    
         (LTolPanel.DoubleFormat         "%0.*e")
         (LTolLabel.Label                "Linear tolerance:")
         (LTolLabel.TopOffset            4)
         (LTolLabel.BottomOffset         4)
         (LTolLabel.LeftOffset           4)
         (LTolLabel.RightOffset          4)
         (ATolPanel.TopOffset            4)
         (ATolPanel.BottomOffset         4)
         (ATolPanel.LeftOffset           4)
         (ATolPanel.RightOffset          4)
         (ATolPanel.InputType            3)
         (ATolPanel.MinDouble            0.0)
         (ATolPanel.DoubleFormat         "%0.*e")       
         (ATolLabel.Label                "Angular tolerance:")
         (ATolLabel.TopOffset            4)
         (ATolLabel.BottomOffset         4)
         (ATolLabel.LeftOffset           4)
         (ATolLabel.RightOffset          4)
         (RTolPanel.TopOffset            4)
         (RTolPanel.BottomOffset         4)
         (RTolPanel.LeftOffset           4)
         (RTolPanel.RightOffset          4)
         (RTolPanel.InputType            3)
         (RTolPanel.MinDouble            0.0)
         (RTolPanel.DoubleFormat         "%0.*e")                                    
         (RTolLabel.Label                "Relative tolerance:")
         (RTolLabel.TopOffset            4)
         (RTolLabel.BottomOffset         4)
         (RTolLabel.LeftOffset           4)
         (RTolLabel.RightOffset          4)
         (.TopOffset                     4)                               
         (.Label                         "Assembly Tolerances")
         (.Decorated                     True)         
         (.Layout
             (Grid (Rows 1 1 1) (Cols 1 1)
                  LTolLabel
                  LTolPanel
                  ATolLabel
                  ATolPanel
                  RTolLabel
                  RTolPanel
              )
         )
     )
 )
 
 (Layout CSOptLayout
    (Components
         (RadioGroup                     CSOptGroup)
         (InputPanel                     PrefixPanel)   
         (Label                          DummyLabel)      
    )

    (Resources
        (CSOptGroup.Orientation         True) 
        (CSOptGroup.Labels              "Do not export coordinate systems" "Export only CSs with this prefix:                                     ") 
        (CSOptGroup.Names               "NONE" "PREFIX") 
        (PrefixPanel.TopOffset          4)
        (PrefixPanel.BottomOffset       2)
        (PrefixPanel.LeftOffset         32)
        (PrefixPanel.RightOffset        4)
        (PrefixPanel.InputType          0)
        (DummyLabel.Label               "                      ")     
        (.TopOffset                     4)                      
        (.Label                         "Export Coordinate Systems")
        (.Decorated                     True)
        (.Layout
            (Grid (Rows 1 1) (Cols 1)
                CSOptGroup
                (Grid (Rows 1) (Cols 1 1)
                    PrefixPanel
                    DummyLabel
                )
            )
        )
    )
)

 (Layout CADOptLayout
    (Components
         (RadioGroup                     CADOptGroup)     
    )

    (Resources
        (CADOptGroup.Orientation         True) 
        (CADOptGroup.Labels              "STEP" "STL                                                                                  ") 
        (CADOptGroup.Names               "STEP" "STL")     
        (.TopOffset                     4)                      
        (.Label                         "Geometry File Format")
        (.Decorated                     True)
        (.Layout
            (Grid (Rows 1) (Cols 1)
                CADOptGroup
            )
        )
    )
)


