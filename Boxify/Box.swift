//
//  Box.swift
//  AR Testbed
//
//  Created by Alun Bestor on 2017-06-16.
//  Copyright © 2017 Alun Bestor. All rights reserved.
//

import SceneKit

class Box: SCNNode {
	enum Edge {
		case min, max
	}
	
	enum Side: String {
		case front, back
		case top, bottom
		case left, right
		
		var axis: SCNVector3.Axis {
			switch self {
			case .left, .right: return .x
			case .top, .bottom: return .y
			case .front, .back: return .z
			}
		}
		
		var edge: Edge {
			switch self {
			case .back, .bottom, .left: return .min
			case .front, .top, .right: return .max
			}
		}
	}
	
	enum HorizontalAlignment {
		case left, right, center
		
		var anchor: Float {
			switch self {
			case .left: return 0
			case .right: return 1
			case .center: return 0.5
			}
		}
	}
	
	enum VerticalAlignment {
		case top, bottom, center
		
		var anchor: Float {
			switch self {
			case .bottom: return 0
			case .top: return 1
			case .center: return 0.5
			}
		}
	}
	
	let labelMargin = Float(0.01)
	
	let lineWidth = CGFloat(0.005)
	
	let vertexRadius = CGFloat(0.005)
	
	let fontSize = Float(0.025)
	
	/// Don't show labels on axes that are less than this length
	let minLabelDistanceThreshold = Float(0.01)
	
	/// At heights below this, the box will be flattened until it becomes completely 2D
	let minHeightFlatteningThreshold = Float(0.05)
	
	let lengthFormatter: NumberFormatter
	
	// Bottom vertices
	lazy var vertexA: SCNNode = self.makeVertex()
	lazy var vertexB: SCNNode = self.makeVertex()
	lazy var vertexC: SCNNode = self.makeVertex()
	lazy var vertexD: SCNNode = self.makeVertex()
	
	// Top vertices
	lazy var vertexE: SCNNode = self.makeVertex()
	lazy var vertexF: SCNNode = self.makeVertex()
	lazy var vertexG: SCNNode = self.makeVertex()
	lazy var vertexH: SCNNode = self.makeVertex()
	
	// Bottom lines
	lazy var lineAB: SCNNode = self.makeLine()
	lazy var lineBC: SCNNode = self.makeLine()
	lazy var lineCD: SCNNode = self.makeLine()
	lazy var lineDA: SCNNode = self.makeLine()
	
	// Top lines
	lazy var lineEF: SCNNode = self.makeLine()
	lazy var lineFG: SCNNode = self.makeLine()
	lazy var lineGH: SCNNode = self.makeLine()
	lazy var lineHE: SCNNode = self.makeLine()
	
	// Vertical lines
	lazy var lineAE: SCNNode = self.makeLine()
	lazy var lineBF: SCNNode = self.makeLine()
	lazy var lineCG: SCNNode = self.makeLine()
	lazy var lineDH: SCNNode = self.makeLine()
	
	lazy var widthLabel: SCNNode = self.makeLabel()
	lazy var heightLabel: SCNNode = self.makeLabel()
	lazy var lengthLabel: SCNNode = self.makeLabel()
	
	lazy var faceBottom: SCNNode = self.makeFace(for: .bottom)
	lazy var faceTop: SCNNode = self.makeFace(for: .top)
	lazy var faceLeft: SCNNode = self.makeFace(for: .left)
	lazy var faceRight: SCNNode = self.makeFace(for: .right)
	lazy var faceFront: SCNNode = self.makeFace(for: .front)
	lazy var faceBack: SCNNode = self.makeFace(for: .back)
	
	//MARK: - Constructors
	
	override init() {
		self.lengthFormatter = NumberFormatter()
		self.lengthFormatter.numberStyle = .decimal
		self.lengthFormatter.maximumFractionDigits = 1
		self.lengthFormatter.multiplier = 100
		
		super.init()
		
		resizeTo(min: .zero, max: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func makeNode(with geometry: SCNGeometry) -> SCNNode {
		for material in geometry.materials {
			material.lightingModel = .constant
			material.diffuse.contents = UIColor.white
			material.isDoubleSided = false
		}
		
		let node = SCNNode(geometry: geometry)
		self.addChildNode(node)
		return node
	}
	
	fileprivate func makeVertex() -> SCNNode {
		let ball = SCNSphere(radius: vertexRadius)
		return makeNode(with: ball)
	}
	
	fileprivate func makeLine() -> SCNNode {
		let box = SCNBox(width: lineWidth, height: lineWidth, length: lineWidth, chamferRadius: 0)
		return makeNode(with: box)
	}
	
	fileprivate func makeLabel() -> SCNNode {
		// NOTE: SCNText font sizes are measured in the same coordinate systems as everything else, so font size 1.0 means a font that's 1 metre high.
		// For some reason very small font sizes gave incorrect results (e.g. invisible/misplaced geometry), so we handle font sizing using scale instead.
		
		let text = SCNText(string: "", extrusionDepth: 0.0)
		text.font = UIFont.boldSystemFont(ofSize: 1.0)
		text.flatness = 0.01
		
		let node = makeNode(with: text)
		node.setUniformScale(fontSize)
		
		return node
	}
	
	fileprivate func makeFace(for side: Side) -> SCNNode {
		let plane = SCNPlane()
		let node = makeNode(with: plane)
		node.name = side.rawValue
		node.geometry?.firstMaterial?.transparency = 0.1
		node.geometry?.firstMaterial?.writesToDepthBuffer = false
		
		// Rotate each face to the appropriate facing
		switch side {
		case .top:
			node.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX)
		case .bottom:
			node.orientation = SCNQuaternion(radians: Float.pi / 2, around: .axisX)
		case .front:
			break
		case .back:
			node.orientation = SCNQuaternion(radians: Float.pi, around: .axisY)
		case .left:
			node.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisY)
		case .right:
			node.orientation = SCNQuaternion(radians: Float.pi / 2, around: .axisY)
		}
		
		return node
	}
	
	//MARK: - Transformation
	
	fileprivate func setOpacity(_ opacity: CGFloat, for side: Side) {
		guard let face = childNode(withName: side.rawValue, recursively: false) else {
			fatalError("No face found for \(side)")
		}
		face.geometry?.firstMaterial?.transparency = opacity
		face.geometry?.firstMaterial?.writesToDepthBuffer = (opacity >= 1.0)
	}
	
	func highlight(side: Side) {
		setOpacity(1.0, for: side)
	}
	
	func clearHighlights() {
		for (side, _) in faces {
			setOpacity(0.1, for: side)
		}
	}
	
	var faces: [Side: SCNNode] {
		return [
			.top: faceTop,
			.bottom: faceBottom,
			.left: faceLeft,
			.right: faceRight,
			.front: faceFront,
			.back: faceBack,
		]
	}
	
	func move(side: Side, to extent: Float) {
		var (min, max) = boundingBox
		switch side.edge {
		case .min: min.setAxis(side.axis, to: extent)
		case .max: max.setAxis(side.axis, to: extent)
		}
		
		resizeTo(min: min, max: max)
	}
	
	func resizeTo(min minExtents: SCNVector3, max maxExtents: SCNVector3) {
		// Normalize the bounds so that min is always < max
		let absMin = SCNVector3(x: min(minExtents.x, maxExtents.x), y: min(minExtents.y, maxExtents.y), z: min(minExtents.z, maxExtents.z))
		let absMax = SCNVector3(x: max(minExtents.x, maxExtents.x), y: max(minExtents.y, maxExtents.y), z: max(minExtents.z, maxExtents.z))
		
		boundingBox = (absMin, absMax)
		update()
	}
	
	fileprivate func update() {
		let (minBounds, maxBounds) = boundingBox
		
		let size = maxBounds - minBounds
		
		assert(size.x >= 0 && size.y >= 0 && size.z >= 0)
		
		let A = SCNVector3(x: minBounds.x, y: minBounds.y, z: minBounds.z)
		let B = SCNVector3(x: maxBounds.x, y: minBounds.y, z: minBounds.z)
		let C = SCNVector3(x: maxBounds.x, y: minBounds.y, z: maxBounds.z)
		let D = SCNVector3(x: minBounds.x, y: minBounds.y, z: maxBounds.z)
		
		let E = SCNVector3(x: minBounds.x, y: maxBounds.y, z: minBounds.z)
		let F = SCNVector3(x: maxBounds.x, y: maxBounds.y, z: minBounds.z)
		let G = SCNVector3(x: maxBounds.x, y: maxBounds.y, z: maxBounds.z)
		let H = SCNVector3(x: minBounds.x, y: maxBounds.y, z: maxBounds.z)
		
		vertexA.position = A
		vertexB.position = B
		vertexC.position = C
		vertexD.position = D
		
		vertexE.position = E
		vertexF.position = F
		vertexG.position = G
		vertexH.position = H
		
		updateLine(lineAB, from: A, distance: size.x, axis: .x)
		updateLine(lineBC, from: B, distance: size.z, axis: .z)
		updateLine(lineCD, from: C, distance: -size.x, axis: .x)
		updateLine(lineDA, from: D, distance: -size.z, axis: .z)
		
		updateLine(lineEF, from: E, distance: size.x, axis: .x)
		updateLine(lineFG, from: F, distance: size.z, axis: .z)
		updateLine(lineGH, from: G, distance: -size.x, axis: .x)
		updateLine(lineHE, from: H, distance: -size.z, axis: .z)
		
		updateLine(lineAE, from: A, distance: size.y, axis: .y)
		updateLine(lineBF, from: B, distance: size.y, axis: .y)
		updateLine(lineCG, from: C, distance: size.y, axis: .y)
		updateLine(lineDH, from: D, distance: size.y, axis: .y)
		
		updateFace(faceTop)
		updateFace(faceBottom)
		updateFace(faceLeft)
		updateFace(faceRight)
		updateFace(faceFront)
		updateFace(faceBack)
		
		// Align width label along the front bottom edge of box, flat against the ground
		updateLabel(widthLabel, distance: size.x, horizontalAlignment: .center, verticalAlignment: .top)
		widthLabel.position = pointInBounds(at: SCNVector3(x: 0.5, y: 0, z: 1)) + SCNVector3(x: 0, y: 0, z: labelMargin)
		widthLabel.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX)
		
		// Align length label along right bottom edge of box, flat against the ground
		updateLabel(lengthLabel, distance: size.z, horizontalAlignment: .center, verticalAlignment: .top)
		lengthLabel.position = pointInBounds(at: SCNVector3(x: 1, y: 0, z: 0.5)) + SCNVector3(x: labelMargin, y: 0, z: 0)
		lengthLabel.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX).concatenating(SCNQuaternion(radians: Float.pi / 2, around: .axisY))
		
		// Align height label to top left edge of box, parallel to the box's vertical axis
		updateLabel(heightLabel, distance: size.y, horizontalAlignment: .right, verticalAlignment: .top)
		heightLabel.position = pointInBounds(at: SCNVector3(x: 0, y: 1, z: 1)) + SCNVector3(x: -labelMargin, y: 0, z: 0)
		
		widthLabel.isHidden = size.x < minLabelDistanceThreshold
		heightLabel.isHidden = size.y < minLabelDistanceThreshold
		lengthLabel.isHidden = size.z < minLabelDistanceThreshold
		
		// At very low heights, flatten the box until it becomes 2D.
		let horizontalNodes = [
			vertexA, vertexB, vertexC, vertexD,
			vertexE, vertexF, vertexG, vertexH,
			lineAB, lineBC, lineCD, lineDA,
			lineEF, lineFG, lineGH, lineHE,
		]
		
		let flatteningRatio = min(size.y, minHeightFlatteningThreshold) / minHeightFlatteningThreshold
		for node in horizontalNodes {
			node.scale = SCNVector3(x: 1, y: flatteningRatio, z: 1)
		}
	}
	
	fileprivate func updateLine(_ line: SCNNode, from position: SCNVector3, distance: Float, axis: SCNVector3.Axis) {
		guard let box = line.geometry as? SCNBox else {
			fatalError("Tried to update something that is not a line")
		}
		
		let absDistance = CGFloat(abs(distance))
		let offset = distance * 0.5
		switch axis {
		case .x:
			box.width = absDistance
			line.position = position + SCNVector3(x: offset, y: 0, z: 0)
		case .y:
			box.height = absDistance
			line.position = position + SCNVector3(x: 0, y: offset, z: 0)
		case .z:
			box.length = absDistance
			line.position = position + SCNVector3(x: 0, y: 0, z: offset)
		}
	}
	
	fileprivate func updateFace(_ face: SCNNode) {
		guard let plane = face.geometry as? SCNPlane, let name = face.name, let side = Side(rawValue: name) else {
			fatalError("Tried to update something that is not a face")
		}
		
		let (min, max) = boundingBox
		let size = max - min
		
		let anchor: SCNVector3
		let dimensions: (width: Float, height: Float)
		switch side {
		case .top:
			dimensions = (size.x, size.z)
			anchor = SCNVector3(x: 0.5, y: 1, z: 0.5)
		case .bottom:
			dimensions = (size.x, size.z)
			anchor = SCNVector3(x: 0.5, y: 0, z: 0.5)
		case .front:
			dimensions = (size.x, size.y)
			anchor = SCNVector3(x: 0.5, y: 0.5, z: 1)
		case .back:
			dimensions = (size.x, size.y)
			anchor = SCNVector3(x: 0.5, y: 0.5, z: 0)
		case .left:
			dimensions = (size.z, size.y)
			anchor = SCNVector3(x: 0, y: 0.5, z: 0.5)
		case .right:
			dimensions = (size.z, size.y)
			anchor = SCNVector3(x: 1, y: 0.5, z: 0.5)
		}
		
		plane.width = CGFloat(dimensions.width)
		plane.height = CGFloat(dimensions.height)
		face.position = pointInBounds(at: anchor)
	}
	
	fileprivate func updateLabel(_ label: SCNNode, distance distanceInMetres: Float, horizontalAlignment: HorizontalAlignment, verticalAlignment: VerticalAlignment) {
		guard let text = label.geometry as? SCNText else {
			fatalError("Tried to update something that is not a label")
		}
		
		text.string = lengthFormatter.string(for: NSNumber(value: distanceInMetres))! + " cm"
		let textAnchor = text.pointInBounds(at: SCNVector3(x: horizontalAlignment.anchor, y: verticalAlignment.anchor, z: 0))
		label.pivot = SCNMatrix4(translation: textAnchor)
	}
}
