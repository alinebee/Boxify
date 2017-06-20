//
//  SCNNode+Extensions.swift
//  AR Testbed
//
//  Created by Alun Bestor on 2017-06-17.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import SceneKit

extension SCNBoundingVolume {
	// Returns a point at a specified normalized location within the bounds of the volume, where 0 is min and 1 is max.
	func pointInBounds(at normalizedLocation: SCNVector3) -> SCNVector3 {
		let boundsSize = boundingBox.max - boundingBox.min
		let locationInPoints = boundsSize * normalizedLocation
		return locationInPoints + boundingBox.min
	}
}
