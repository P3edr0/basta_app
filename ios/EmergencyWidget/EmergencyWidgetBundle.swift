//
//  EmergencyWidgetBundle.swift
//  EmergencyWidget
//
//  Created by Pedro Kamargo on 05/08/26.
//

import WidgetKit
import SwiftUI

@main
struct EmergencyWidgetBundle: WidgetBundle {
    var body: some Widget {
        EmergencyWidget()
        EmergencyWidgetControl()
    }
}
