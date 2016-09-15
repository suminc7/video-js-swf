﻿package org.papervision3d.core.geom {	import org.papervision3d.core.culling.IObjectCuller;	import org.papervision3d.core.geom.renderables.Vertex3D;	import org.papervision3d.core.math.Matrix3D;	import org.papervision3d.core.math.Number3D;	import org.papervision3d.core.proto.GeometryObject3D;	import org.papervision3d.core.render.data.RenderSessionData;	import org.papervision3d.objects.DisplayObject3D;		/**	* The Vertices3D class lets you create and manipulate groups of vertices.	*	*/	public class Vertices3D extends DisplayObject3D	{		/**		* Creates a new Vertices3D object.		*		*		* @param	vertices	An array of Vertex3D objects for the vertices of the mesh.		* <p/>		*/		public function Vertices3D(vertices:Array, name:String=null )		{			super( name, new GeometryObject3D() );			this.geometry.vertices = vertices || new Array();		}		/**		 * Clones this object.		 * 		 * @return	The cloned DisplayObject3D.		 */ 		public override function clone():DisplayObject3D		{			var object:DisplayObject3D = super.clone();			var verts:Vertices3D = new Vertices3D(null, object.name);						verts.material = object.material;			if(object.materials)				verts.materials = object.materials.clone();							if(this.geometry)				verts.geometry = this.geometry.clone(verts);							verts.copyTransform(this);						return verts;		}				/**		* Projects three dimensional coordinates onto a two dimensional plane to simulate the relationship of the camera to subject.		*		* This is the first step in the process of representing three dimensional shapes two dimensionally.		*		* @param	camera		Camera.		*/		public override function project( parent :DisplayObject3D,  renderSessionData:RenderSessionData ):Number		{			super.project( parent, renderSessionData );			if( this.culled )				return 0;							if( renderSessionData.camera is IObjectCuller )				return projectFrustum(parent, renderSessionData);						if(!this.geometry || !this.geometry.vertices)				return 0;							return renderSessionData.camera.projectVertices(this.geometry.vertices, this, renderSessionData);		}				public function projectEmpty(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number{						return super.project( parent, renderSessionData );		}		/**		 * 		 * @param	parent		 * @param	camera		 * @param	sorted		 * @return		 */		public function projectFrustum( parent :DisplayObject3D, renderSessionData:RenderSessionData ):Number 		{			return 0;		}				/**		* Calculates 3D bounding box.		*		* @return	{min : Number3D, max : Number3D, size : Number3D}		*/		public function boundingBox():Object		{			var vertices :Array = this.geometry.vertices;			var bBox     :Object = new Object();			bBox.min  = new Number3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);			bBox.max  = new Number3D(-Number.MAX_VALUE, -Number.MAX_VALUE, -Number.MAX_VALUE);			bBox.size = new Number3D();			for each(var v:Vertex3D in vertices)			{				bBox.min.x = Math.min( v.x, bBox.min.x );				bBox.min.y = Math.min( v.y, bBox.min.y );				bBox.min.z = Math.min( v.z, bBox.min.z );								bBox.max.x = Math.max( v.x, bBox.max.x );				bBox.max.y = Math.max( v.y, bBox.max.y );				bBox.max.z = Math.max( v.z, bBox.max.z );			}			bBox.size.x = bBox.max.x - bBox.min.x;			bBox.size.y = bBox.max.y - bBox.min.y;			bBox.size.z = bBox.max.z - bBox.min.z;			return bBox;		}		/**		* Calculates 3D bounding box in world space.		*		* @return	{minX, maxX, minY, maxY, minZ, maxZ}		*/				public function worldBoundingBox () : Object		{						// TODO requires optimisation : would be better to apply world matrix to local bounds			var vertices : Array = this.geometry.vertices ;						var bBox :Object = new Object();						bBox.min = new Number3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);			bBox.max = new Number3D(-Number.MAX_VALUE, -Number.MAX_VALUE, -Number.MAX_VALUE);			bBox.size = new Number3D();						var tempV : Number3D ;						for each(var v:Vertex3D in vertices)			{				tempV = v.getPosition () ;				Matrix3D.multiplyVector ( this.world, tempV ) ;								bBox.min.x = Math.min ( tempV.x, bBox.min.x );				bBox.min.y = Math.min ( tempV.y, bBox.min.y );				bBox.min.z = Math.min ( tempV.z, bBox.min.z );								bBox.max.x = Math.max ( tempV.x, bBox.max.x );				bBox.max.y = Math.max ( tempV.y, bBox.max.y );				bBox.max.z = Math.max ( tempV.z, bBox.max.z );			}						bBox.size.x = bBox.max.x - bBox.min.x;			bBox.size.y = bBox.max.y - bBox.min.y;			bBox.size.z = bBox.max.z - bBox.min.z;						return bBox;		}		public function transformVertices( transformation:Matrix3D ):void		{						geometry.transformVertices(transformation);		}	}}