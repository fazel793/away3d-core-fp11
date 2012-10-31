package away3d.animators.nodes
{
	import away3d.animators.data.AnimationRegisterCache;
	import away3d.animators.states.ParticleBezierCurveByLifeGlobalState;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.passes.MaterialPassBase;
	import flash.geom.Vector3D;
	/**
	 * ...
	 */
	public class ParticleBezierCurveByLifeGlobalNode extends GlobalParticleNodeBase
	{
		public static const NAME:String = "ParticleBezierCurvelByLifeGlobalNode";
		public static const BEZIER_CONSTANT_REGISTER:int = 0;
		private var _controlPoint:Vector3D;
		private var _endPoint:Vector3D;
		
		public function ParticleBezierCurveByLifeGlobalNode(control:Vector3D,end:Vector3D)
		{
			super(NAME);
			_stateClass = ParticleBezierCurveByLifeGlobalState;
			
			_controlPoint = control;
			_endPoint = end;
		}
		
		public function get controlPoint():Vector3D
		{
			return _controlPoint;
		}
		
		public function set controlPoint(value:Vector3D):void
		{
			_controlPoint = value;
		}
		
		public function get endPoint():Vector3D
		{
			return _endPoint;
		}
		
		public function set endPoint(value:Vector3D):void
		{
			_endPoint = value;
		}
		
		override public function getAGALVertexCode(pass:MaterialPassBase, animationRegisterCache:AnimationRegisterCache) : String
		{
			var _controlConst:ShaderRegisterElement = animationRegisterCache.getFreeVertexConstant();
			animationRegisterCache.setRegisterIndex(this, BEZIER_CONSTANT_REGISTER, _controlConst.index);
			var _endConst:ShaderRegisterElement = animationRegisterCache.getFreeVertexConstant();
			
			var temp:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			var rev_time:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "x");
			var time_2:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "y");
			var time_temp:ShaderRegisterElement = new ShaderRegisterElement(temp.regName, temp.index, "z");
			animationRegisterCache.addVertexTempUsages(temp, 1);
			var temp2:ShaderRegisterElement = animationRegisterCache.getFreeVertexVectorTemp();
			var distance:ShaderRegisterElement = new ShaderRegisterElement(temp2.regName, temp2.index, "xyz");
			animationRegisterCache.removeVertexTempUsage(temp);
			
			var code:String = "";
			code += "sub " + rev_time.toString() + "," + animationRegisterCache.vertexOneConst.toString() + "," + animationRegisterCache.vertexLife.toString() + "\n";
			code += "mul " + time_2.toString() + "," + animationRegisterCache.vertexLife.toString() + "," + animationRegisterCache.vertexLife.toString() + "\n";
			
			code += "mul " + time_temp.toString() + "," + animationRegisterCache.vertexLife.toString() +"," + rev_time.toString() + "\n";
			code += "mul " + time_temp.toString() + "," + time_temp.toString() +"," + animationRegisterCache.vertexTwoConst.toString() + "\n";
			code += "mul " + distance.toString() + "," + time_temp.toString() +"," + _controlConst.toString() + "\n";
			code += "add " + animationRegisterCache.offsetTarget.toString() +".xyz," + distance.toString() + "," + animationRegisterCache.offsetTarget.toString() + ".xyz\n";
			code += "mul " + distance.toString() + "," + time_2.toString() +"," + _endConst.toString() + "\n";
			code += "add " + animationRegisterCache.offsetTarget.toString() +".xyz," + distance.toString() + "," + animationRegisterCache.offsetTarget.toString() + ".xyz\n";
			
			if (animationRegisterCache.needVelocity)
			{
				code += "mul " + time_2.toString() + "," + animationRegisterCache.vertexLife.toString() + "," + animationRegisterCache.vertexTwoConst.toString() + "\n";
				code += "sub " + time_temp.toString() + "," + animationRegisterCache.vertexOneConst.toString() + "," + time_2.toString() + "\n";
				code += "mul " + time_temp.toString() + "," + animationRegisterCache.vertexTwoConst.toString() + "," + time_temp.toString() + "\n";
				code += "mul " + distance.toString() + "," + _controlConst.toString() + "," + time_temp.toString() + "\n";
				code += "add " + animationRegisterCache.velocityTarget.toString() + ".xyz," + distance.toString() + "," + animationRegisterCache.velocityTarget.toString() + ".xyz\n";
				code += "mul " + distance.toString() + "," + _endConst.toString() + "," + time_2.toString() + "\n";
				code += "add " + animationRegisterCache.velocityTarget.toString() + ".xyz," + distance.toString() + "," + animationRegisterCache.velocityTarget.toString() + ".xyz\n";
			}
			
			return code;
		}
		
		
	}

}