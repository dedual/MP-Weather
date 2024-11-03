//
//  DeviceRotationModifier.swift
//  MP-Weather
//
//  Created by Nicolas Dedual on 11/3/24.
//

import SwiftUI

struct DeviceRotationModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationModifier(action: action))
    }
}
