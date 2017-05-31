//
//  WaveformView.swift
//  Wilbur
//
//  Created by Ben Sullivan on 28/05/2016.
//  Copyright © 2016 Sullivan Applications. All rights reserved.
//

import FDWaveformView

extension FDWaveformView {
  
  open override func awakeFromNib() {
    
    wavesColor = UIColor(colorLiteralRed: 96/255, green: 148/255, blue: 252/255, alpha: 1.0)
  }
}
