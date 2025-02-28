package h3d.pass;

class CapsuleShadowMap extends CubeShadowMap {

	var pshader : h3d.shader.PointShadow;

	public function new( light : h3d.scene.Light, useWorldDist : Bool ) {
		super(light, useWorldDist);
		shader = pshader = new h3d.shader.PointShadow();
	}

	override function set_mode(m:Shadows.RenderMode) {
		pshader.enable = m != None && enabled;
		return mode = m;
	}

	override function set_enabled(b:Bool) {
		pshader.enable = b && mode != None;
		return enabled = b;
	}

	override function getShadowTex() {
		return pshader.shadowMap;
	}

	override function syncShader(texture) {
		if( texture == null )
			throw "assert";
		var capsuleLight = cast(light, h3d.scene.pbr.CapsuleLight);
		pshader.shadowMap = texture;
		pshader.shadowBias = bias;
		pshader.shadowPower = power;
		pshader.lightPos = light.getAbsPos().getPosition();
		pshader.zFar = capsuleLight.range + capsuleLight.length;

		// ESM
		pshader.USE_ESM = samplingKind == ESM;
		pshader.shadowPower = power;

		// PCF
		pshader.USE_PCF = samplingKind == PCF;
		pshader.pcfScale = pcfScale / 100.0;
		pshader.pcfQuality = pcfQuality;
	}

	override function createCollider(light : h3d.scene.Light) {
		var absPos = light.getAbsPos();
		var capsuleLight = cast(light, h3d.scene.pbr.CapsuleLight);
		// TODO : Optimize culling
		return new h3d.col.Sphere(absPos.tx, absPos.ty, absPos.tz, capsuleLight.range + capsuleLight.length * 0.5);
	}

	override function cull(lightCollider, col) {
		var sphere = cast(lightCollider, h3d.col.Sphere);
		return col.inSphere(sphere);
	}

	override function updateLightCameraNearFar(light : h3d.scene.Light) {
		var capsuleLight = cast(light, h3d.scene.pbr.CapsuleLight);
		lightCamera.zFar = capsuleLight.range;
		lightCamera.zNear = capsuleLight.zNear;
	}
}