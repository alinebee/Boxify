//
//  SCNMatrix4+Extensions.swift
//  AR Testbed
//
//  Created by Alun Bestor on 2017-06-17.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import SceneKit

extension SCNMatrix4 {
	//MARK: - Initializers
	
	init(translation: SCNVector3) {
		self = SCNMatrix4MakeTranslation(translation.x, translation.y, translation.z)
	}
	
	init(translationByX x: Float, y: Float, z: Float) {
		self = SCNMatrix4MakeTranslation(x, y, z)
	}
	
	init(scale: SCNVector3) {
		self = SCNMatrix4MakeScale(scale.x, scale.y, scale.z)
	}
	
	init(scaleByX x: Float, y: Float, z: Float) {
		self = SCNMatrix4MakeScale(x, y, z)
	}
	
	init(rotationByRadians angle: Float, around axis: SCNVector3) {
		self = SCNMatrix4MakeRotation(angle, axis.x, axis.y, axis.z)
	}
	
	//MARK: - Operations
	
	func translated(by translation: SCNVector3) -> SCNMatrix4 {
		return SCNMatrix4Translate(self, translation.x, translation.y, translation.z)
	}
	
	func rotated(byRadians angle: Float, around axis: SCNVector3) -> SCNMatrix4 {
		return SCNMatrix4Rotate(self, angle, axis.x, axis.y, axis.z)
	}
	
	func scaled(byX x: Float, y: Float, z: Float) -> SCNMatrix4 {
		return SCNMatrix4Scale(self, x, y, z)
	}
}
