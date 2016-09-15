/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.ascollada.core {
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeEntity;	
	import org.ascollada.namespaces.collada;

	/**
	 * 
	 */
	public class DaeSampler extends DaeEntity
	{	
		use namespace collada;
		
		/**  */
		public var type:String;
		
		/**  */
		public var values:Array;
		
		/** */
		public var input : DaeSource;
		
		/** */
		public var output : DaeSource;
		
		/** */
		public var interpolation : DaeSource;
		
		/** */
		public var in_tangent : DaeSource;
		
		/** */
		public var out_tangent : DaeSource;
		
		/**
		 * 
		 * @param	node
		 *  
		 * @return
		 */
		public function DaeSampler(document:DaeDocument, node:XML ):void
		{
			super( document, node );
		}

		/**
		 * 
		 */
		override public function destroy() : void {
			super.destroy();
			this.input = null;
			this.output = null;
			this.interpolation = null;
			this.in_tangent = null;
			this.out_tangent = null;
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		override public function read( node:XML ):void
		{		
			if( node.localName() != ASCollada.DAE_SAMPLER_ELEMENT )
				throw new Error( "expected a '" + ASCollada.DAE_SAMPLER_ELEMENT + "' element" );
				
			super.read( node );
			
			var list : XMLList = node.input;
			var child : XML;
			var input : DaeInput;
			var num : int = list.length();
			var i : int;
			
			for(i = 0; i < num; i++) {
				child = list[i];
				
				input = new DaeInput(this.document, child);
				
				switch(input.semantic) {
					case "INPUT":
						this.input = this.document.sources[input.source];
						break;
					case "OUTPUT":
						this.output = this.document.sources[input.source];
						break;
					case "INTERPOLATION":
						this.interpolation = this.document.sources[input.source];
						break;
					case "IN_TANGENT":
						this.in_tangent = this.document.sources[input.source];
						break;
					case "OUT_TANGENT":
						this.out_tangent = this.document.sources[input.source];
						break;
					default:
						trace("[DaeSampler] unhandled semantic: " + input.semantic);
						break;			
				}
			}
		}
		
	}
}
