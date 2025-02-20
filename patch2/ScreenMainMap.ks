;
;
; ScreenMainMap.ks
;
;
;
[jump target="*mainmap"]
;クラス定義
*classinit
[if exp="typeof(dynamicbutton_object.screen.mainmap) == 'undefined'"]
[iscript]
{
	//スクリーンクラス
	class _SCREEN_TEMP_CLASS
	{
	
		var tartgetCount = -1;		//選択拠点
		var tartgetCountTo = -1;	//移動先
		
		var focusLock = 0;
		
		var listcount = 0;
		//var listcountview = [];
		var listcountarr = [];
		
		var mapmode = 0;
		
		var unitstatsview_number = -1;
		
		var czone1 = [ 930, 50, 930, 110, 930, 170,   930, 250, 930, 310, 930, 370, 930, 430, 930, 490, 930, 550, 930, 610 ];
		
		var czone2 = [ 0, 50, 0, 110, 0, 170,   0, 250, 0, 310, 0, 370, 0, 430, 0, 490, 0, 550, 0, 610 ];
			
		//var cameraBuckUpX = 0, cameraBuckUpY = 0, cameraBuckUpZ;
			
		var fillButtonCover;	
			
		function _SCREEN_TEMP_CLASS(){}
	
		//function setCameraBackup()
		//{
			//cameraBuckUpX = pMmapview.d3layer.CAMERA[0];
			//cameraBuckUpY = pMmapview.d3layer.CAMERA[1];
			//cameraBuckUpZ = pMmapview.d3layer.CAMERA[2];
		//}
		//
		//function getCameraBackup()
		//{
			//pMmapview.setCameraPos(cameraBuckUpX, cameraBuckUpY, cameraBuckUpZ);
		//}
		
		/**
		 * 画面の拡大縮小
		 * @param	x
		 * @param	y
		 */
		function onScreenMapMVFiledAll(x,y)
		{
			_DYN_.lock();
			//core2.timerEventCaller.Stop();
			core2.standardTimer.Stop();
			
			kag.process( ,"*viewzoom_control" );
			
			if( pMmapview.d3layer.CAMERA[2] < pMmapview.cameraMax[4] ) {

				var uv = pMmapview.setCameraPosLimit( [pMmapview.d3layer.CAMERA[0],pMmapview.d3layer.CAMERA[1],pMmapview.cameraMax[4]] );
				
				var str = "(%d,%d,%d,%d)".sprintf( uv[0], uv[1], uv[2], uv[3] );
				
				pMmapview.d3layer.moveEndTrigerCallback = "viewzoom_control";
				pMmapview.d3layer.beginMove( %[ time:500, path:str, accel: -3 ]);
				
			} else if( pMmapview.d3layer.CAMERA[2] >= pMmapview.cameraMax[3]-10 ) {
				
				var ux = (2900*(x/1280))-1450;
				var uy = (1900*(y/700))-950;
				var uv = pMmapview.setCameraPosLimit( [ux,uy,pMmapview.cameraMax[4]] );
				
				var str = "(%d,%d,%d,%d)".sprintf( -uv[0], uv[1], uv[2], uv[3] );
				pMmapview.d3layer.moveEndTrigerCallback = "viewzoom_control";
				pMmapview.d3layer.beginMove( %[ time:1000, path:str, accel: -3 ]);
				
			} else {
			
				pMmapview.d3layer.moveEndTrigerCallback = "viewzoom_control";
				pMmapview.d3layer.beginMove( %[ time:1000, path:"(0,250,%d,10)".sprintf(pMmapview.cameraMax[3]), accel: -3 ]);
				
			}
		}
		
		/**
		 * 画面の拡大縮小 終了
		 */
		function onScreenMapMVFiledAll_end()
		{
			pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			core2.standardTimer.Play();
		}
		
		/**
		 * 画面移動
		 * @param	x
		 * @param	y
		 */
		function onMoveMapFiled(x,y)
		{
			
			if(dynamicbutton_object.snapPosButtons.button==0) {
			
				core2.standardTimer.Stop();

				var xx = dynamicbutton_object.snapPosButtons.x-x;
				var yy = dynamicbutton_object.snapPosButtons.y-y;
				
				pMmapview.setCameraPosA( -xx, +yy );
				
				dynamicbutton_object.snapPosButtons.x = x;
				dynamicbutton_object.snapPosButtons.y = y;
				
				//dm("onMoveMapFiled= %s,%s".sprintf(pMmapview.d3layer.CAMERA[0],pMmapview.d3layer.CAMERA[1]));
				//core2.timerEventCaller.draw();
				
				pMmapview.updateDraw();
				//core2.standardTimer.onDraw();
				
			}
		}
		
		/**
		 * 画面移動 終了
		 * @param	x
		 * @param	y
		 * @param	button
		 * @param	shift
		 */
		function onMoveMapFiledup(x, y, button, shift)
		{
			if ( button == 1 ) {
				//viewRoomStatasResetTown();
				//setupMapModeTop();
				//if ( pMmapview.moveMode != 0 ) setupMapModeTop();
				//return;
				
			//} else {
				//core2.standardTimer.Play();
				//pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			//}
			}
			core2.standardTimer.Play();
			
			pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			
			pMmapview.setCameraBackup();
		}
		
		/**
		 * 画面の拡大縮小 ホイール
		 * @param	d
		 */
		function onMoveMapFiledW(d)
		{
			var mv = 0;
			//if (d < 0) mv = -(10 + (5 * (d\120))); else mv = +(10 + (5 * (d\120)));
			//mv = -d\12;
			if (d < 0) mv = 20; else mv = -20;
			
			//var yy = pMmapview.d3layer.CAMERA[2] + mv;
			
			pMmapview.setCameraPos( ,, pMmapview.d3layer.CAMERA[2] + mv );
			
			pMmapview.updateDraw();
			
			pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			
			pMmapview.setCameraBackup();
				
		}
		
		//function onScreenMapSCFiled()
		//{
			//if( pMmapview.d3layer.DTYPE == stFastLinear ) pMmapview.d3layer.DTYPE = stNearest;
			//else pMmapview.d3layer.DTYPE = stFastLinear;
			//
			//pMmapview.updateDraw();
			//_DYN_.unlock();
		//}
	
		//function onScreenMapMVFiled(x)
		//{
			//pMmapview.d3layer.modeChange(1);
			//pMmapview.d3layer.modeChange2(1,0.5,0.5);
			//pMmapview.d3layer.moveFinalFunction = moveFinalFunction;
			//pMmapview.d3layer.beginMove( %[ time:1000, path:x, accel: -3 ]);
		//}
		
		//function moveFinalFunction() {
			//pMmapview.d3layer.modeChange(0);
			//pMmapview.d3layer.modeChange2(1,1,1);
			//pMmapview.updateDraw();
			//pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			//kag.trigger('moved_control'); //saveloadトリガ発動
		//}
		
		/**
		 * 拠点エンター
		 * @param	n
		 * @param	x
		 * @param	y
		 */
		function viewRoomEnter(n,x,y)
		{
			pMmapview.d3layer.enterTarget[0] = x;
			pMmapview.d3layer.enterTarget[1] = y;
			pMmapview.d3layer.enterTarget[2] = 150;
				
			pMmapview.updateDraw();
			
			var fm = n.split('_');	
			if ( fm[0] == 'f') {
				
				var e = _getQuarters(fm[1]);
				
				//拠点ステータス
				if ( mapmode == 0 || mapmode == 2) {
					topside_sutat_draws_Quarters(fm[1]);
				}
			
				if (e.party != 1 && e.party != 0 && (mapmode == 0 || mapmode == 2)) {
					topside_sutat_draws_em(e.corps, e.party, false );
				}
				
				if (e.party == 1 && mapmode == 0 ) {
					topside_sutat_draws_ar2(e.corps);
				}
			}
		}
		
		/**
		 * 拠点リーブ
		 */
		function viewRoomLeave()
		{	
			pMmapview.d3layer.enterTarget[2] = -1;
			pMmapview.updateDraw();
			
			if( mapmode == 0 || mapmode == 2 ) {
				//拠点ステータス
				topside_sutat_draws_Quarters( -1);
				topside_sutat_draws_em( -1);
			}
			
			if( mapmode == 0 ) {
				topside_sutat_draws_ar2( -1);
			}
		}
		
		/**
		 * 拠点クリック
		 * @param	n
		 */
		function viewRoomStatasEnter(n)
		{
			//_DYNTXT_.clear();
			
			_DSCR.top_draw();
			
			//viewRoomStatasEnterTown(n, focusLock);
			
			switch( pMmapview.moveMode ) {
				case 0: viewRoomStatasEnterTown(n,focusLock); break;
				case 1: viewRoomStatasEnterUnits(n, focusLock); break;
				case 3: viewRoomStatasEnterTown(n,focusLock); break;
			}
		}
		
		//function viewRoomStatasEnterZ(n)
		//{
			//switch( pMmapview.moveMode ) {
				//case 0: viewRoomStatasEnterTown(n,1); break;
			//}
		//}
		
		/**
		 * 
		 */
		//function viewRoomStatasResetTown()
		//{
			//pMmapview.moveUnitsStack.clear();
			//
			//_DSCR.top_draw();
			//
			//tartgetCount = -1;
			//tartgetCountTo = -1;
			//
			//pMmapview.d3layer.focusTarget[2] = -1;
			//
			//setupMapMode(0);
			//
			//for ( var i = 0; i < 12; i ++ ) {
				//_DYNBT_[45].locksn( i, 2 );
			//}
			//_DYNBT_[45].visible = false;
			//
			//
			//pMmapview.d3layer.enterTarget[0] = 0;
			//pMmapview.d3layer.enterTarget[1] = 0;
			//pMmapview.d3layer.enterTarget[2] = -1;
			//
			//上段ステータス更新
			//top_draw();
			//
			//地上表示データ更新
			//pMmapview.setupUpdateDraw( n, tartgetCount );
			//
			//全体描写更新
			//pMmapview.updateDraw();
//
			//反応領域更新
			//pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			//
			//周期書き換え実行
			//core2.timerEventCaller.draw();
			//pMmapview.updateDraw();
			//
		//}
		
		/**
		 * 拠点クリック 通常
		 * @param	n
		 * @param	fc
		 */
		function viewRoomStatasEnterTown(n,fl)
		{
			//配置情報モード
			
			//dm("viewRoomStatasEnterTown= %s, %s".sprintf(n,tartgetCount));
			//viewRoomStatasResetTown();
			
			//var fm = pMmapview.getClipDraw2(n).split('_');
			var fm = n.split('_');
			
			if( fm[0]=='f') {
				
				kag.se[0].play(%[storage:'TMA1_click9town']);
				_DYNBT_[20].onMouseLeave();
				_DYN_.lock();
				
				mapmode = 1;
				
				var xyo = [ -pMmapview.d3layer.CAMERA[0], pMmapview.d3layer.CAMERA[1] ];
				
				tartgetCount = fm[1];
				
				var xy = pMmapview.datas.chip[tartgetCount][2];
				
				var r = pMmapview.setCameraPosLimit( [ xy[0] -1450, xy[1] - 950 ] );
				var ux = r[0]; 
				var uy = r[1];
				
				pMmapview.d3layer.focusTarget[0] = xy[0];
				pMmapview.d3layer.focusTarget[1] = xy[1];
				pMmapview.d3layer.focusTarget[2] = 150;
				
				//pMmapview.d3layer.movingLayer.vecX = xy[0] -1450;
				//pMmapview.d3layer.movingLayer.vecY = -(xy[1] - 950);
				
				//setupMapMode(3);
				pMmapview.setupUpdateDraw(3, tartgetCount);
			
				//拠点ステータス
				topside_sutat_draws_Quarters(tartgetCount);
			
				topside_sutat_draw( tartgetCount );
				
				dm("viewRoomStatasEnterTown= %s, %s,%s".sprintf(tartgetCount,ux,uy));
				/*
				if (fc) {
					
					var mvx = Math.abs(ux - xyo[0]);
					var mvy = Math.abs(uy - xyo[1]);
					var ktime = Math.sqrt((mvx * mvx) + (mvy * mvy));
					
					kag.process( , "*moved_control" );
					
					//var str = "(%d,%d,%d,%d)".sprintf( -ux, uy, pMmapview.d3layer.CAMERA[2], pMmapview.d3layer.CAMERA[3] );
					var str = "(%d,%d,0,25)".sprintf( -ux, uy );
					
					pMmapview.d3layer.moveEndTrigerCallback = "view_control";
					//pMmapview.d3layer.moveFinalFunction = moveFinalFunction;
					pMmapview.d3layer.beginMove( %[ time:1000, path:str, accel: -3 ] );
					
				}
				*/
				//move test
				//pMmapview.SAVED.units[2][3].add(pMmapview.getClipDraw2(n));
				
				//else 
				_DYN_.unlock();
				
				//setupMapMode(3);
				//地上表示データ更新
				//if( pMmapview.moveMode != 3 ) 
				
				//pMmapview.setupUpdateDraw(3);
				//pMmapview.setupUpdateDraw(0);
				
				pMmapview.updateDraw();
				
				//pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
				
			} else if ( fm[0] == 'd') {
				
				//kag.se[0].play( % [storage:'se0102_抜刀音シキィン'] );
				kag.se[0].play( % [storage:'TMA1_click94a'] );
				//setupMapMode(1, 0 );
				
				//移動モード 突入
				mapmode = 2;
			
				tartgetCount = uf.pDivi[fm[1]].pos[0];
				
				var xy = pMmapview.datas.chip[tartgetCount][2];
				
				pMmapview.d3layer.focusTarget[0] = xy[0];
				pMmapview.d3layer.focusTarget[1] = xy[1];
				pMmapview.d3layer.focusTarget[2] = 150;
				
				/////
				//pMmapview.moveUnitsStack.clear();
				//pMmapview.moveUnitsStack[fm[2]] = fm[1];
				pMmapview.moveUnitsStack[fm[2]] = fm[1];
				pMmapview.moveUnitsStackCount = 1;
				
				dm("viewRoomStatasEnterTown.set[%s]=%s,%s %s,%s".sprintf( fm[2], fm[1], n, 
				
				//uf.pDivi[fm[1]].leader, uf.pUnit[uf.pDivi[fm[1]].leader].image1[5] ));
				uf.pUnit[uf.pDivi[fm[1]].divo[uf.pDivi[fm[1]].leader]].name,
				uf.pUnit[uf.pDivi[fm[1]].divo[uf.pDivi[fm[1]].leader]].image1[5]
				 ));
				
				var sel = [0, 0, 0];
				for ( var i = 0; i < 3; i++ ) {
					if ( pMmapview.moveUnitsStack[i] !== void ) { sel[i] = 5; }
				}
			
				setupMapMode(1, pMmapview.moveUnitsStackCount, sel );
				
				topside_sutat_draws_mv( pMmapview.moveUnitsStack, _getQuarters(tartgetCount).corps );
					
				//uf.quarters[tartgetCount].corps[fm[2]] = void;
				
				//pMmapview.moveUnitsStack.add(fm[1]);
				//var sel = [0, 0, 0];
				//for ( var i = 0; i < 3; i++ ) {
					//if ( pMmapview.moveUnitsStack[i] !== void ) { sel[i] = 5; }
				//}
				//
				//setupMapMode(1, pMmapview.moveUnitsStackCount, sel );
				//
				////setupMapMode(2);
				//
				////topside_sutat_draws_Quarters(tartgetCount);
				//
				//topside_sutat_draws_mv( pMmapview.moveUnitsStack, _getQuarters(tartgetCount).corps );
				//
				
				//pMmapview.setMoveLayers2( 1, _getQuarters(tartgetCount).corps, tartgetCount, 0 );
				
				//pMmapview.setMoveLayers( 1, pMmapview.moveUnitsStack );
				
			}
			
		}
		
		/**
		 * 拠点クリック 移動
		 * @param	n
		 * @param	fc
		 */
		function viewRoomStatasEnterUnits(n,fl)
		{
			//var fm = pMmapview.getClipDraw2(n).split('_');
			var fm = n.split('_');

			if( fm[0]=='f') {
				
				//移動モード 移動開始選択
				mapmode = 3;
				
				_DYN_.lock();
				pMMenueview.lock();
				
				tartgetCountTo = fm[1];
				
				set_add_map_units_init();
				
				
			} else if ( fm[0] == 'd') {
				
				//kag.se[0].play( % [storage:'se0102_抜刀音シキィン'] );
				kag.se[0].play( % [storage:'TMA1_click94a'] );
				
				//移動モード 選択＆選択解除
				
				if ( pMmapview.moveUnitsStack[fm[2]] === void )
				{
					pMmapview.moveUnitsStack[fm[2]] = fm[1];
				} else {
					pMmapview.moveUnitsStack[fm[2]] = void;
				}

				pMmapview.moveUnitsStackCount = 0;
				for ( var i = 0; i < 3; i++ ) {
					if ( pMmapview.moveUnitsStack[i] !== void ) pMmapview.moveUnitsStackCount++;
				}
				
				/*
				if (pMmapview.moveUnitsStackCount == 0)
				{ 
					topside_sutat_draws_mv( pMmapview.moveUnitsStack, _getQuarters(tartgetCount).corps );
					pMmapview.updateDraw();
					
				} else {
					
					//モード解除
					setupMapModeTop();
				}
				*/
				
				var tm = false;
				for ( var i = 0; i < 3; i++ ) {
					if ( pMmapview.moveUnitsStack[i] !== void ) { tm = true; break; }
				}

				dm("viewRoomStatasEnterUnits= %s,%s,%s".sprintf( fm[1], fm[2], pMmapview.moveUnitsStackCount ));
				
				if (tm)
				{
					var sel = [0, 0, 0];
					for ( var i = 0; i < 3; i++ ) {
						if ( pMmapview.moveUnitsStack[i] !== void ) { sel[i] = 5; }
					}
				
					setupMapMode(1, pMmapview.moveUnitsStackCount, sel );
					
					topside_sutat_draws_mv( pMmapview.moveUnitsStack, _getQuarters(tartgetCount).corps );
					
					//pMmapview.updateDraw();
					
					//core2.timerEventCaller.draw();
			
				} else {
					
					//モード解除
					setupMapModeTop();
				}
				
			}
		}

		function set_add_map_units(n)
		{
			var uq = _getQuarters(n);
			var tg = _getQuarters(tartgetCount);
			
			//uf.quarters[n].party = 1;
			uq.party = 1;
			
			for ( var i = 0; i < 3; i++ )
			{
				if ( pMmapview.moveUnitsStack[i] !== void ) {
					
					//uf.quarters[n].corps.add( pMmapview.moveUnitsStack[i] );
					//uf.quarters[tartgetCount].corps.erase(i);
					uq.corps.add( pMmapview.moveUnitsStack[i] );
					tg.corps.erase(i);
				}
				
				pMmapview.moveUnitsStack[i] = void;
				
				dm("set_add_map_units= %s,%s".sprintf( uq.corps[i], pMmapview.moveUnitsStack[i] ));
			}
			
			pMmapview.moveUnitsStack.clear();
			pMmapview.moveUnitsStackCount = 0;
			
			ca3.onUpdate_Quarters2Div();

		}
		
		function set_add_map_units_init()
		{
			//
			/*
			var tm = [];
			tm.assignStruct( uf.quarters[tartgetCount].corps );
			uf.quarters[tartgetCount].corps.clear();
			
			for ( var i = 0; i < 3; i++ )
			{
				dm("set_add_map_units_init= %s,%s (%s)%s ->".sprintf(
					i, pMmapview.moveUnitsStack[i], tartgetCount, tm[i] ));
					
				if ( tm[i] !== void ) {
					if( tm[i] != pMmapview.moveUnitsStack[i] ) uf.quarters[tartgetCount].corps.add( tm[i] );
				}
				
			}
			
			for ( var i = 0; i < 3; i++ )
			{
				dm("set_add_map_units_init= %s,%s".sprintf(
					i, uf.quarters[tartgetCount].corps[i] ));
				
			}
			
			tm.assignStruct( pMmapview.moveUnitsStack );
			pMmapview.moveUnitsStack.clear();
			
			for ( var i = 0; i < 3; i++ ) {
				if ( tm[i] !== void ) {
					pMmapview.moveUnitsStack.add( tm[i] );
				}
			}
			*/
			
			//core2.standardTimer.Stop();
			//core2.standardTimer.Pause();
			core2.standardTimer.Stop();
			
			var xyf, xyt;
			
			xyf = pMmapview.datas.chip[tartgetCount][2];
			xyt = pMmapview.datas.chip[tartgetCountTo][2];
			
			var mvXy = xyt[0] - xyf[0];
			//var xyj2 = Math.abs(xyt[1] - xyf[1]);
			var mvTime = Math.abs(mvXy);
			if ( mvTime < 500 ) mvTime = 500;
			if ( mvTime > 1000 ) mvTime = 1000;
			
			dm("set_add_map_units_init= (%s,%s)->(%s,%s)=%s,%s".sprintf( xyf[0],xyf[1],  xyt[0],xyt[1], mvXy, mvTime ) );
			
			var xy, xys, ux, uy;

			pMmapview.setMoveLayers( 1, tartgetCount );
			//pMmapview.setMoveLayers2( 1, _getQuarters(tartgetCount).corps, tartgetCount );
			//pMmapview.setMoveLayers( 1, uf.quarters[tartgetCount].corps, ux );
			//pMmapview.setMoveLayers( 1, pMmapview.moveUnitsStack, ux );
			
			kag.process( , "*moved_control" );
			
			var str;
			//= "(%d,%d,%d,0)".sprintf( ux, -uy, 150);
			//var i;
			var uq = _getQuarters(tartgetCountTo);
			var ip = 0;
			if ( uq.party == 1 ) ip = uq.corps.count;
			
			var ig = 0;
			
			var lst = -1, dtime = 0;
			for ( var i = 0; i < 3; i++ ) {
				
				if ( pMmapview.movingLayer[i].visible ) {
					
					//pMmapview.movingLayer[i].lockPos = 0;
					
					if ( pMmapview.moveUnitsStack[i] !== void )
					{
						xy = pMmapview.datas.chip[tartgetCountTo][2];
						//xys = pMmapview.datas.chip[tartgetCount][2];
						
						dm("set_add_map_units= %s".sprintf( ip ));
						
						//ux = xy[0] -1450;
						//uy = xy[1] - 950;
						
						//ux = xy[0] -1450;
						//uy = xy[1] - 950;
						
						ux = xy[0] -1450 + pMmapview.UNITS_POS[ip][0];
						uy = xy[1] - 950 + pMmapview.UNITS_POS[ip][1];
						
						str = "(%d,%d,%d,0)".sprintf( ux, -uy, pMmapview.UNITS_POS[ip][2]);
						
						//str = "(%d,%d,%d,0),(%d,%d,%d,0)".sprintf( (xys[0] -1450), -(xys[1] - 950), 150, ux, -uy, 150);
						
						var fc = pMmapview.getUnitFcs( tartgetCount, 1 );
						if ( ( mvXy > 0 && fc == 0 ) || ( mvXy < 0 && fc == 1 ) ) pMmapview.movingLayer[i].tempLayer.flipLR();
						
						ip++;
						
						pMmapview.movingLayer[i].update();
						//pMmapview.focusModeMove = 1;
						//pMmapview.movingLayer[0].movedCameraCall = void;
						//pMmapview.movingLayer[i].lockPos = 0;
						//pMmapview.movingLayer[i].focusMode = focusLock;
						//if( i == 0 ) pMmapview.d3layer.movingLayer[i].moveEndTrigerCallback = "moved_control";
						//pMmapview.d3layer.movingLayer[i].moveFinalFunction = set_add_map_units_end_check;
						//pMmapview.d3layer.movingLayer[i].beginMove( % [ time:1000, path:str, accel: -2 ] );
						
						pMmapview.movingLayer[i].beginMove( % [ time:mvTime, path:str, accel:-2 ] );
						
						
						
						//pMmapview.d3layer.movingLayer[i].beginMove( % [ delay:dtime, time:mvTime, path:str ] );
						
						//dtime += 500;
						
						/*
						xy = pMmapview.datas.chip[tartgetCountTo][2];
						
						//ux = xy[0] -1450;
						//uy = xy[1] - 950;
						ux = xy[0] -1450 + pMmapview.UNITS_POS[i][0];
						uy = xy[1] - 950 + pMmapview.UNITS_POS[i][1];
						
						str = "(%d,%d,%d,0)".sprintf( ux, -uy, 150);
						
						pMmapview.d3layer.movingLayer[i].focusMode = focusLock;
						if( i == 0 ) pMmapview.d3layer.movingLayer[i].moveEndTrigerCallback = "moved_control";
						//pMmapview.d3layer.movingLayer[i].moveFinalFunction = set_add_map_units_end_check;
						//pMmapview.d3layer.movingLayer[i].beginMove( % [ time:1000, path:str, accel: -2 ] );
						
						pMmapview.d3layer.movingLayer[i].beginMove( % [ time:5000, path:str, accel: -2 ] );
						
					} else {
						
						xy = pMmapview.datas.chip[tartgetCount][2];
						
						ux = xy[0] -1450 + pMmapview.UNITS_POS[i][0];
						uy = xy[1] - 950 + pMmapview.UNITS_POS[i][1];
						
						str = "(%d,%d,%d,0)".sprintf( ux, -uy, 150);
						
						pMmapview.d3layer.movingLayer[i].focusMode = focusLock;
						if( i == 0 ) pMmapview.d3layer.movingLayer[i].moveEndTrigerCallback = "moved_control";
						//pMmapview.d3layer.movingLayer[i].moveFinalFunction = set_add_map_units_end_check;
						//pMmapview.d3layer.movingLayer[i].beginMove( % [ time:1000, path:str, accel: -2 ] );
						
						pMmapview.d3layer.movingLayer[i].beginMove( % [ time:5000, path:str, accel: -2 ] );
						*/
						
					} else {
						
						//ux = pMmapview.d3layer.movingLayer[i].vecX;
						//uy = pMmapview.d3layer.movingLayer[i].vecY;
						
						xy = pMmapview.datas.chip[tartgetCount][2];
						//xys = pMmapview.datas.chip[tartgetCount][2];
						
						//ux = xy[0] -1450;
						//uy = xy[1] - 950;
						
						//ux = xy[0] -1450;
						//uy = xy[1] - 950;
						
						ux = xy[0] -1450 + pMmapview.UNITS_POS[ig][0];
						uy = xy[1] - 950 + pMmapview.UNITS_POS[ig][1];
						
						
						
						str = "(%d,%d,%d,0)".sprintf( ux, -uy, pMmapview.UNITS_POS[ig][2]);
						
						ig++;
						
						pMmapview.movingLayer[i].update();
						//pMmapview.movingLayer[i].lockPos = 0;
						pMmapview.movingLayer[i].beginMove( % [ delay:dtime, time:mvTime, path:str, accel:-2 ] );
						
						//dtime += 500;
					}
					
					lst = i;
				}
			}
			
			//pMmapview.movingLayer[0].updateDraw = true;
			//pMmapview.movingLayer[0].endVisible = true;
			pMmapview.movingLayer[0].moveEndTrigerCallback = "moved_control";
			
			//if ( lst != -1 ) pMmapview.d3layer.movingLayer[lst].moveEndTrigerCallback = "moved_control";
			
			setupMapMode(2);
			
			//kag.se[0].play( %[storage:'TMA1_click83'] );
			kag.se[0].play( %[storage:'TMA1_se10'] );
			
		}
		
		function set_add_map_units_end_check()
		{	
			//for ( var i = 0; i < 3; i++ ) {
				//pMmapview.movingLayer[i].visible = false;
			//}
			
			mapmode = 4;
			
			for ( var i = 0; i < 3; i++ )
			{
				if ( pMmapview.moveUnitsStack[i] !== void ) {
					uf.pDivi[pMmapview.moveUnitsStack[i]].state = 1;
				}
			}
			
			//if ( uf.quarters[tartgetCountTo].party != 1 && uf.quarters[tartgetCountTo].corps.count > 0 )
			if ( _getQuarters(tartgetCountTo).party != 1 && _getQuarters(tartgetCountTo).corps.count > 0 )
			{
			
				mapmode = 5;
				
				var ex = [ 1, 2, 0 ];
				var tm = [];
				for ( var i = 0; i < 3; i++ ) {
				if ( pMmapview.moveUnitsStack[i] !== void ) {
						tm.add( pMmapview.moveUnitsStack[i] );
					}
				}
				
				var te = [];
				for ( var i = 0; i < 3; i++ ) {
					if ( _getQuarters(tartgetCountTo).corps[i] !== void ) {
						te.add( _getQuarters(tartgetCountTo).corps[i] );
					}
				}
				
				var d = pMmapview.datas.chip[tartgetCountTo];
				var m = gf.mapbase[d[0]];
				var geo = gf.geograph[m.geograph + (uf.game.timeZone * 50)];
			
				ca2.onMainBattleDataSet(
					tm,
					te,
					[geo,m], false, 0 );
					
				dm( "set_add_map_units_end_check= (%s)%s[%s,%s,%s]->(%s)%s[%s,%s,%s],%s".sprintf(
					tartgetCount,tm.count,tm[0],tm[1],tm[2], tartgetCountTo,te.count,te[0],te[1],te[2],  (m.geograph + (uf.game.timeZone * 50))
				));
				
				kag.process( , "*battle_control" );
	
			} else {
				
				
				set_add_map_units_end();
				
				core2.standardTimer.Play();
				
				_DYN_.unlock();
				
			}
		}
		
		/**
		 * 移動最終処理
		 * @param	n=false	敗北時復帰するか?
		 */
		function set_add_map_units_end()
		{
			
			var e = pMmapview.datas.chip[tartgetCountTo];
			if( _getQuarters(tartgetCountTo).party != 1 ) ca2.onDomainGet( gf.mapbase[e[0]] );
			
			//set_add_map_units_end_exec(n);
			pMmapview.set_add_map_units_end_exec( 0, 1, tartgetCount, tartgetCountTo );
			
			for ( var i = 0; i < 3; i++ ) {
				pMmapview.movingLayer[i].visible = false;
				//pMmapview.movingLayer[i].update();
			}
			
			//viewRoomStatasResetTown();
			
			setupMapModeTop();
			
			//core2.timerEventCaller.draw();
			//pMmapview.updateDraw();
			
			//roc.onMoveDiviEnd( '*onEventThrow' );
			roc.onMoveDiviEnd( '*dialog_control' );
			pMMenueview.lock();
		}
		
		/**
		 * 移動最終処理 全滅処理
		 * @param	n=false	敗北時復帰するか?
		 */
		function set_add_map_units_end_battle(n=0)
		{
			var em = n[0];
			
			if (em > 0) ca3.vbh_setDivi_voiceAddlose(pMmapview.moveUnitsStack);
			
			pMmapview.set_add_map_units_end_battle( em, tartgetCount, tartgetCountTo );
			
			if (em <= 0) ca3.vbh_setDivi_voiceAddwin(pMmapview.moveUnitsStack, tartgetCountTo);
			
			pMmapview.set_add_map_units_end_exec( em, 1, tartgetCount, tartgetCountTo );
			pMMenueview.lock();
		}
		
		/**
		 * 移動最終処理 全滅処理
		 * @param	n=false	敗北時復帰するか?
		 */
		/*
		function set_add_map_units_end_battle(n=0)
		{
			
			//自軍
			var uq = _getQuarters(tartgetCount);
			
			for ( var i = 0; i < 3; i++ )
			{
				if ( pMmapview.moveUnitsStack[i] !== void )
				{	
					//var uq = uf.quarters[tartgetCount];
					var p = ca2.life_calcDivs( pMmapview.moveUnitsStack[i], 0 );
					
					//dm("set_add_map_units_end_battle[%s]= %s, %s".sprintf( i, p[0], p[1] ));
					
					//ライフ補正
					ca2.divi_unit_lifeup_ck( pMmapview.moveUnitsStack[i] );
					
					//全滅の場合
					if ( p[0] == 0 ) {
		
						//dm("set_add_map_units_end_battle[%s]= %s, %s".sprintf( i, p[0], p[1] ));
						
						//バックアップから消去
						for ( var j = 0; j < 3; j++ ) {
							if ( uq.corps[j] !== void && uq.corps[j] == pMmapview.moveUnitsStack[i] ) {
								//uq.corps.erase(j);
								uq.corps[j] = void;
								break;
							}
						}

						//移動データから消去
						pMmapview.moveUnitsStack[i] = void;
						uf.mapcache.pNow--;
						
					}
				}
			}
			
			//voidをつめる
			var tm = [];
			for ( var i = 0; i < 3; i++ ) {
				if ( uq.corps[i] !== void ) tm.add(uq.corps[i]);
			}
			uq.corps = tm;
			
			//敵軍
			//for ( var i = 0; i < 3; i++ )
			//{
				//if ( uf.quarters[tartgetCountTo].corps[i] !== void ) {
				//if ( _getQuarters(tartgetCountTo).corps[i] !== void ) {
					//
					//if (n[0] > 0)
					//{
						//勝利
						//var uq = uf.quarters[tartgetCountTo];
						//var uq = _getQuarters(tartgetCountTo);
						//var p = ca2.life_calcDivs( uq.corps[i], 1 );
						//
						//全滅の場合
						//if ( p[0] == 0 ) {
//
							//uf.eDivi[uq.corps[i]].enable = false;
							//
							//uq.corps.erase(i);
							//
							//バックアップから消去
							//uq.corpsm.erase(i);
//
							//uf.mapcache.eNow--;
							//
						//}	
					//} else
					//{
						//敗北
						//var uq = uf.quarters[tartgetCountTo];
						//var uq = _getQuarters(tartgetCountTo);
						//
						//uf.eDivi[uq.corps[i]].enable = false;
						//
						//uq.corps.erase(i);
						//
						//バックアップから消去
						//uq.corpsm.erase(i);
//
						//uf.mapcache.eNow--;
					//}
				//}
			//}
			//for ( var i = 0; i < 3; i++ )
			//{
				//if ( uf.quarters[tartgetCountTo].corps[i] !== void ) {
				//if ( _getQuarters(tartgetCountTo).corps[i] !== void ) {
					uq = _getQuarters(tartgetCountTo);
					
					if (n[0] > 0)
					{
						//勝利
						//var uq = uf.quarters[tartgetCountTo];
						
						for ( var i = 0; i < 3; i++ )
						{
							if ( uq.corps[i] !== void )
							{
								var p = ca2.life_calcDivs( uq.corps[i], 1 );
								
								//全滅の場合
								if ( p[0] == 0 ) {

									uf.eDivi[uq.corps[i]].enable = false;
									
									//バックアップから消去
									//uq.corps.erase(i);
									uq.corps[i] = void;
									uf.mapcache.eNow--;
								}
							}
						}
						
						//voidをつめる
						var tm = [];
						for ( var i = 0; i < 3; i++ ) {
							if ( uq.corps[i] !== void ) tm.add(uq.corps[i]);
						}
						uq.corps = tm;
						
					} else
					{
						//敗北
						var uq = _getQuarters(tartgetCountTo);
						
						for ( var i = 0; i < 3; i++ )
						{
							if ( uq.corps[i] !== void ) {
								uf.eDivi[uq.corps[i]].enable = false;
								uf.mapcache.eNow--;
							}
						}	
						uq.corps.clear();
					}
				//}
			//}
			
			set_add_map_units_end_exec(n[0]);
			
		}
		*/
		
		/**
		 * 移動最終処理 実行部
		 * @param	n=false
		 */
		/*
		function set_add_map_units_end_exec(n=0)
		{
			
			//敗北の場合移動処理はしない
			if (n <= 0)
			{
				//移動先を占領
				_getQuarters(tartgetCountTo).party = 1;
			
	
				//移動元の師団を削除
				var tm = [];
				tm.assignStruct( _getQuarters(tartgetCount).corps );
				
				_getQuarters(tartgetCount).corps.clear();
				
				for ( var i = 0; i < 3; i++ ) {
					if ( tm[i] !== void && pMmapview.moveUnitsStack[i] === void ) {
						_getQuarters(tartgetCount).corps.add( tm[i] );
					}
				}
			
				//移動先に師団を移動
				for ( var i = 0; i < 3; i++ ) {
					if ( pMmapview.moveUnitsStack[i] !== void ) {
						_getQuarters(tartgetCountTo).corps.add( pMmapview.moveUnitsStack[i] );
					}
				}
				
				//データ更新
				ca3.vbh_update_Data();
			}
		}
		*/
		
		//モード設定
		function focusLockMode()
		{
			focusLock = !focusLock;
			pMmapview.focusMode = focusLock;
			_DYN_.unlock();
		}
		
		/**
		 * マップ表示モード切替
		 * @param	n=void
		 */
		function setupMapMode( n=void, rn=0, sel )
		{

			if(rn==0) {
				pMmapview.d3layer.enterTarget[0] = 0;
				pMmapview.d3layer.enterTarget[1] = 0;
				pMmapview.d3layer.enterTarget[2] = -1;
			}
			
			//上段ステータス更新
			top_draw();
			
			//地上表示データ更新
			pMmapview.setupUpdateDraw( n, tartgetCount, rn, sel );
			
			//全体描写更新
			pMmapview.updateDraw();

			//反応領域更新
			pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			
			//周期書き換え実行
			//core2.timerEventCaller.draw();
			//pMmapview.updateDraw();
			
		}
		
		/**
		 * 初期マップ表示モード切替
		 */
		function setupMapModeTop( lod = false )
		{
			mapmode = 0;
			
			pMmapview.moveUnitsStack.clear();
			pMmapview.moveUnitsStackCount = 0;
			
			tartgetCount = -1;		//選択拠点
			tartgetCountTo = -1;	//移動先
			
			pMmapview.d3layer.focusTarget[0] = 0;
			pMmapview.d3layer.focusTarget[1] = 0;
			pMmapview.d3layer.focusTarget[2] = -1;
			
			pMmapview.d3layer.enterTarget[0] = 0;
			pMmapview.d3layer.enterTarget[1] = 0;
			pMmapview.d3layer.enterTarget[2] = -1;
			
			if (_DYNBT_[35] !== void) {
				for ( var i = 0; i < 12; i ++ ) _DYNBT_[35].locksn( i, 2 );
				_DYNBT_[35].inFlag = -1;
				_DYNBT_[35].targetBt.visible = false;
				_DYNBT_[35].visible = false;
				_DYNBT_[99].visible = false;
			}
			
			if (_DYNBT_[30] !== void) {
				for ( var i = 0; i < 12; i ++ ) _DYNBT_[30].locksn( i, 2 );
				_DYNBT_[30].inFlag = -1;
				_DYNBT_[30].targetBt.visible = false;
				_DYNBT_[30].visible = false;
			}
			
			for ( var i = 0; i < 3; i++ ) {
				pMmapview.movingLayer[i].visible = false;
				//dm("pMmapview.movingLayer[%s].visible= %s".sprintf(i,pMmapview.movingLayer[i].visible));
			}
			
			//師団高速表示用データ更新
			ca3.vbh_update_DiviData();
			
			//quartersからdivを更新
			ca3.onUpdate_Quarters2Div();
			
			//上段ステータス更新
			top_draw();
			
			//地上表示データ更新
			pMmapview.setupUpdateDraw(0);
			
			//全体描写更新
			pMmapview.updateDraw(lod);

			//反応領域更新
			if (_DYNBT_[20] !== void) pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			
			_DYN_.setHelpLayers( %[storage:'help_rootmap01'] );
			
			//周期書き換え実行
			//core2.timerEventCaller.draw();
			//pMmapview.updateDraw();
		}
		
		function infoViewMode()
		{
			pMmapview.d3layer.infoView = !pMmapview.d3layer.infoView;
			_DYN_.unlock();
		}
		
		/**
		 * 上段ステータス表示
		 */
		function top_draw()
		{
			_BFL1.loadImages( 'bc_mini1' );
			
			_DYNTXT_.clear();
			
			_draw_image_file_( _DYNTXT_, 0, 0, "root_ui_top" );
			
			//自軍
			for ( var i = 0; i < uf.mapcache.ptopDiv.count; i ++ )
			//for ( var j=0,i = uf.quartersview.count-1; i >=0; i --,j++ )
			{	
				//[ ボタンフラグ, 認識番号, 敵フラグ, [空間座標x, y] ];
				//var p = uf.pDivi[uf.quartersview[i]];
				var p = uf.pDivi[uf.mapcache.ptopDiv[i]];
				
				//if ( p !== void && p.leader > -1 )
				if ( p !== void && p.enable )
				{
					var fm = uf.pUnit[p.divo[p.leader]].image1[6];
					var fm = p.datatmp[2][p.leader];

					if ( p.state == 0 ) _BFL1.drawImageFile( _DYNTXT_, 1250-(30*i), 0, fm );
					else _BFL1.drawImageFile( _DYNTXT_, 1250-(30*i), 0, fm,,,,, 4 );
				}
			}
			
			//敵
			for ( var i = 0; i < uf.mapcache.etopDiv.count; i ++ )
			{
				var p = uf.eDivi[uf.mapcache.etopDiv[i]];
				
				//if ( p !== void && p.leader > -1 )
				if ( p !== void && p.enable )
				{
					var fm = uf.eUnit[p.divo[p.leader]].image1[6];
					_BFL1.drawImageFile( _DYNTXT_, 30*i, 0, fm );
				}
			}
			
			_BFL1.freeImage();
		}
		
		/**
		 * 拠点情報
		 * @param	n
		 */
		function topside_sutat_draws_Quarters(n)
		{
			
			if (n == -1) {
				//_DYNTXT_.fillRect( 400, 30, 480, 85, 0x00000000 );
				_DYNTXT_.fillRect( 400, 30, 480, 94, 0x00000000 );
				return;
			}
			
			var d = pMmapview.datas.chip[n];
			var m = gf.mapbase[d[0]];
			var s = uf.quarters[m.savedata];
			
			_DYNTXT_.fillRect( 400, 30, 480, 80, 0xaa000000 );
			if ( s.head == 1 ) {
				_DYNTXT_.fillRect( 400, 32, 400, 19, 0xaa880000 );
			} else {
				_DYNTXT_.fillRect( 400, 32, 400, 19, 0xff000000 );
			}
			
			var scol = % [
				農業: 0xff0d8700,
				魔術: 0xffa970ff,
				工業: 0xffff6c00,
				商業: 0xff7d9efe,
				軍事: 0xffd03333,
				医療: 0xff00ffc0
			];
			_DYNTXT_.fillRect( 400, 110, 480, 5, scol[m.admin] );
			//_DYNTXT_.fillRect( 400, 110, 240, 14, scol[m.admin] );
			//_text_draw_super_( _DYNTXT_, 405, 111, "%s拠点".sprintf( m.admin ), 0xffffff, 14 );
			
			if (s.party > 0) {
				_draw_image_file_( _DYNTXT_, 400, 30, 'slg_map_flag2', ,, 0, 80*(s.party-1), 120, 80 );
			}
			
			//_draw_image_file_( _DYNTXT_, 400, 30, pMmapview.d3layer.planes[1],1,, (100 * (e.party + 1)), (135 * d[1]), 100, 135 );
			
			var mbpt = s.party + 1;
			if (mbpt > 3) mbpt = 3;
			_DYNTXT_.operateStretch( 500, 35, 50, 67, pMmapview.d3layer.planes[1], (100 * mbpt), (135 * d[1]), 100, 135 );
			
			_text_draw_super_( _DYNTXT_, 540, 32, "%2d:%s".sprintf( m.index, ca3.get_mapbase_name(m.name)  ), 0xffffff, 20 );
			
			_text_draw_super_( _DYNTXT_, 550, 53, "%s".sprintf( _PARTY_NAMES[s.party] ), 0xcccccc, 14 );
			
			var str1 = "", str2 = "";
			var geo = gf.geograph[m.geograph + (uf.game.timeZone * 50)];
			var e = [], yc = 0, ye = 28;
			e.assign(geo.revise);
			var n= e.count;
			for (var i = 0; i < e.count; i += 2) {
				if ( e[i + 1] != 0 ) {
					
					_text_draw_super_( _DYNTXT_, 570 + yc, 72, e[i], 0xffffff, 16 );
					_text_draw_super_( _DYNTXT_, 570 + yc - 8, 92, "%3d".sprintf( e[i + 1] ), 0xffffff, 16 );
					
					yc += ye;
				}
			}
			
			//_text_draw_super_( _DYNTXT_, 550, 32, "%04d".sprintf( 9999 ), 0xffffff, 214 );
			//_text_draw_super_( _DYNTXT_, 650, 52, " CHAOS:%03d".sprintf( 9999 ), 0xffffff, 16 );
			//_text_draw_super_( _DYNTXT_, 720, 53, "防壁値:%d".sprintf( m.wall ), 0xcccccc, 14 );
			_text_draw_super_( _DYNTXT_, 670, 53, "%s拠点/防壁値:%d".sprintf( m.admin, m.wall ), 0xdddddd, 14 );
			//_text_draw_super_( _DYNTXT_, 405, 111, "%s拠点".sprintf( m.admin ), 0xffffff, 14 );
			//_text_draw_super_( _DYNTXT_, 650, 92, "　番号:%03d".sprintf( d[0] ), 0xffffff, 16 );
			
			_draw_image_file_( _DYNTXT_, 815, 32, 'icon04x4', ,,  0, 0, 16, 16 );
			_draw_image_file_( _DYNTXT_, 815, 52, 'icon04x4', ,, 16, 0, 16, 16 );
			_draw_image_file_( _DYNTXT_, 815, 72, 'icon04x4', ,, 32, 0, 16, 16 );
			_draw_image_file_( _DYNTXT_, 815, 92, 'icon04x4', ,, 48, 0, 16, 16 );
			
			var sts = [];
			sts[0] = int(m.food  * _RES_COEF[uf.game.difficulty][0]);
			sts[1] = int(m.magic * _RES_COEF[uf.game.difficulty][1]);
			sts[2] = int(m.anima * _RES_COEF[uf.game.difficulty][2]);
			sts[3] = int(m.gold  * _RES_COEF[uf.game.difficulty][3]);
			
			_text_draw_super_number_( _DYNTXT_, 832, 32, sts[0], sts[0], [0xffffff, 0x888888], [0], 216 );
			_text_draw_super_number_( _DYNTXT_, 832, 52, sts[1], sts[1], [0xffffff, 0x888888], [0], 216 );
			_text_draw_super_number_( _DYNTXT_, 832, 72, sts[2], sts[2], [0xffffff, 0x888888], [0], 216 );
			_text_draw_super_number_( _DYNTXT_, 832, 92, sts[3], sts[3], [0xffffff, 0x888888], [0], 216 );
			
		}
		
		
		/**
		 * ステータス表示 描写
		 * @param	bf
		 * @param	p
		 * @param	x
		 * @param	y
		 */
		function topside_sutat_draws_onece( bf, p, x, y, nos=1 )
		{
			var ty = 0;
			//var bf = _BFL1.loadImages( 'bc_mini1' );
			
			for ( var j = 0; j < 6; j ++ )
			{
				if ( p.datatmp[2][j] != '' )
				{
					bf.drawImageFile( _DYNTXT_, x + (30 * j), y + 24, p.datatmp[2][j] );
					
					//if ( p.state == 0 ) {
					//
						//bf.drawImageFile( _DYNTXT_, x + (30 * j), y + 24, p.datatmp[2][j] );
						//
						//if (p.leader == j) _DYNTXT_.fillRect( x + (30 * j), y + 23, 30, 2, 0xffffff00 );
						//if ( p.leader == j ) {
							//_DYNTXT_.fillRect( x + (30 * j), y + 24, 30, 2, 0xffff0000 );
							//_DYNTXT_.fillRect( x + (30 * j), y + 52, 30, 2, 0xffff0000 );
							//_DYNTXT_.fillRect( x + (30 * j), y + 24, 2, 30, 0xffff0000 );
							//_DYNTXT_.fillRect( x + (30 * j) + 28, y + 24, 2, 30, 0xffff0000 );
						//}
					//} else {
						//bf.drawImageFile( _DYNTXT_, x + (30 * j), y + 24, p.datatmp[2][j],,,,, 4 );
					//}
					
		
					if (p.leader == j) _DYNTXT_.fillRect( x + (30 * j), y + 22, 30, 2, 0xffffff00 );
				} else _DYNTXT_.fillRect( x + (30 * j), y + 24, 30, 30, 0xff000000 );
			}
			
			if ( p.state != 0 ) {
				_DYNTXT_.colorRect( x, y + 24, 180, 30, 0x000000, 128 );
			}
			
			//_text_draw_super_( _DYNTXT_, x, y + 3, "%2d:%s".sprintf( p.id + 1, p.unique ), 0xffffff, 16 );
			//_text_draw_super_( _DYNTXT_, x, y + 3, "%2d:%s".sprintf( p.index + 1, p.unique ), 0xffffff, 16 );
			
			if (nos) _text_draw_super_( _DYNTXT_, x, y + 3, "%2d:%s".sprintf( p.id + 1, p.unique ), 0xffffff, 16 );
			else _text_draw_super_( _DYNTXT_, x, y + 3, "%s".sprintf( p.unique ), 0xffffff, 16 );
			
			_text_draw_super_( _DYNTXT_, x + 184, y + 36, "%5d/%d".sprintf( p.datatmp[0][0], p.datatmp[0][1]), 0xffffff, 220 );
			
			//_DYNTXT_.fillRect( x + 185, y + 24, 4, 12, 0xfffe0000 );
			_text_draw_super_( _DYNTXT_, x + 185 + 0, y + 24, "%d".sprintf( BC._FLC(p.datatmp[3][0],9999,1) ), 0xfe0000, 214 );
			
			//_DYNTXT_.fillRect( x + 185 + 35, y + 24, 4, 12, 0xffffb905 );
			_text_draw_super_( _DYNTXT_, x + 185 + 37, y + 24, "%d".sprintf( BC._FLC(p.datatmp[3][1],9999,1) ), 0xffb905, 214 );
			
			//_DYNTXT_.fillRect( x + 185 + 70, y + 24, 4, 12, 0xff02ffbf );
			_text_draw_super_( _DYNTXT_, x + 185 + 74, y + 24, "%d".sprintf( BC._FLC(p.datatmp[3][2],9999,1) ), 0x02ffbf, 214 );
			
			//_DYNTXT_.fillRect( x + 185 + 105, y + 24, 4, 12, 0xff00b0fc );
			//_DYNTXT_.fillRect( x + 185 + 111, y + 24, 50, 12, 0xdd00b0fc );
			//_text_draw_super_( _DYNTXT_, x + 185 + 113, y + 24, "%03d".sprintf( BC._FLC(p.datatmp[3][3], 999, 1) ), 0xffffff, 214 );
			_text_draw_super_( _DYNTXT_, x + 185 + 111, y + 24, "%d".sprintf( BC._FLC(p.datatmp[3][3], 999, 1) ), 0x00b0fc, 214 );
			
			//var fcline = [], pfc = p.force;
			////1 = p.force\100, fcline2 = (p.force % 100)\10;
			//
			//_DYNTXT_.fillRect( x + 315,      y, 2, 20, 0xff00ff00 );
			//_DYNTXT_.fillRect( x + 315 + 3,  y, 2, 20, 0xff00ff00 );
			//_DYNTXT_.fillRect( x + 315 + 6,  y, 2, 20, 0xff00ff00 );
			//_DYNTXT_.fillRect( x + 315 + 9,  y, 2, 20, 0xff00ff00 );
			//_DYNTXT_.fillRect( x + 315 + 12, y, 2, 20, 0xff00ff00 );
			
			var pfc = p.force, pfx = [12, 9, 6, 3, 0];
			for ( var j = 0; j < 5; j ++ )
			{
				var pff = 0.0;
				if (pfc > 100) {
					pff = 1.0;
					pfc -= 100;
				} else if (pfc > 0) {
					pff = pfc / 100;
					pfc = 0;
				}
				
				if ( pff > 0.0 ) {
					
					var col = 0xff00ff84;
					if ( pff < 1.0 ) col = 0xfffae500;
					
					var pffy = int(20 * pff);
					_DYNTXT_.fillRect( x + 315 + pfx[j], y + 20 - pffy, 2, pffy, col );
				}
			}
			
			//bf.freeImage();
		}
		
		/**
		 * ステータス表示 友軍 選択
		 * @param	aa=[]
		 * @param	ab=[]
		 */
		function topside_sutat_draws_mv(aa=[],ab=[])
		{
			var ty, p, fm;
			_BFL1.loadImages( 'bc_mini1' );
			
			//_DYNBT_[45].visible = false;
			_DYNBT_[30].visible = false;
			_DYNBT_[35].visible = false;
			_DYNBT_[99].visible = false;
			
			if (aa.count > 0)
			{
				_draw_image_file_( _DYNTXT_, 930, 30, 'root_plate_01', ,, 0, 60, 350, 20 );
				
				ty = 0;
				
				for ( var j = 0; j < 3; j ++ )
				{
					//var i = pMmapview.PEXC[j];
					var i = j;
					
					if ( aa[i] !== void || ab[i] !== void ) {
						
						var ln = 0;
						if (aa[i] !== void)
						{
							ln = 0;
							p = uf.pDivi[aa[i]];
						} else {
							ln = 145;
							p = uf.pDivi[ab[i]];
						}
						
						_draw_image_file_( _DYNTXT_, 930+ln, 50 + ty, 'lines', ,, 90, 50, 20, 60 );
						
						_DYNTXT_.fillRect( 950+ln, 50 + ty, 350, 20, 0xff000000 );
						_DYNTXT_.fillRect( 950+ln, 70 + ty, 350, 40, 0xaa000000 );
						
						topside_sutat_draws_onece( _BFL1, p, 950 + ln, 50 + ty, 1 );
						
					}
					ty += 60;
				}
			}
			_BFL1.freeImage();
		}
		
		
		/**
		 * ステータス表示 友軍拠点
		 * @param	aa=[]
		 * @param	ab=[]
		 * @param	sd=0.0
		 */
		function topside_sutat_draws_ar(aa = [], ab = [], sd = 0.0, smx = 0)
		{
			//_DYNBT_[45].visible = false;
			_DYNBT_[30].visible = false;
			//_DYNBT_[35].visible = false;
			
			if ( aa == -1 ) {
				_DYNBT_[30].visible = false;
				_DYNBT_[35].visible = false;
				_DYNBT_[99].visible = false;
				_DYNTXT_.fillRect( 930, 30, 350, 690, 0x000000000 );
				return;
			}
			
			_DYNTXT_.fillRect( 930, 30, 350, 690, 0x55000000 );
			
			var ty, p, fm, lf;
			_BFL1.loadImages( 'bc_mini1' );
			
			//for ( var i = 0; i < 10; i ++ ) {
			//	_DYNBT_[40].locksn( i, 2 );
			//}
			_DYNBT_[35].locksnA( 2 );
			
			var vbt = false;
			
			_draw_image_file_( _DYNTXT_, 930, 30, 'root_plate_01', ,, 0, 0, 350, 20 );
			
			if (aa.count > 0)
			{
				ty = 0;
				
				for ( var i = 0; i < 3; i ++ )
				{
					//var aae = aa[pMmapview.PEXC[i]];
					var aae = aa[i];
					
					//if (aa[i] !== void)
					if (aae !== void)
					{
						_DYNTXT_.fillRect( 940, 50 + ty, 340, 20, 0xff000000 );
						_DYNTXT_.fillRect( 940, 70 + ty, 340, 40, 0xaa000000 );
						_DYNTXT_.fillRect( 930, 50 + ty, 10, 60, 0xff02ffbf );
						
						//_DYNTXT_.fillRect( 930 + (3 * i), 50 + ty, 10, 60, 0x8802ffbf );
						
						//p = uf.pDivi[aa[i]];
						p = uf.pDivi[aae];
						
						topside_sutat_draws_onece( _BFL1, p, 950, 50 + ty, 1 );
						
						//未行動のみ有効
						//if ( p.state == 0 ) {
							_DYNBT_[35].locksn( i, 0 );
							vbt = true;
						//}
					} else {
						//_DYNTXT_.fillRect( 930, 50 + ty, 350, 60, 0x55000000 );
					}
					ty += 60;
				}
			}
			
			_draw_image_file_( _DYNTXT_, 930, 230, 'root_plate_01', ,, 0, 40, 350, 20 );
			
			_text_draw_super_( _DYNTXT_, 1252, 232, "%2d".sprintf( uf.mapcache.pMax - uf.mapcache.pNow ), 0xffffff, 216 );
			
			//_DYNTXT_.colorRect( 930, 250, 350, 230 + 420, 0x000000, 32 );
			//_DYNTXT_.fillRect( 930, 250, 350, 420, 0x55000000 );
			
			if (ab.count > 0)
			{
				ty = 0;
				
				for ( var i = 0; i < ab.count; i ++ )
				{
						
					//_DYNTXT_.colorRect( 930, 250 + ty, 350, 60, 0x000000, 128 );
					//_DYNTXT_.fillRect( 930, 250 + ty, 350, 60, 0x99000000 );
					_DYNTXT_.fillRect( 930, 250 + ty, 350, 20, 0xff000000 );
					_DYNTXT_.fillRect( 930, 270 + ty, 350, 40, 0xaa000000 );
						
					p = uf.pDivi[ab[i]];
					
					topside_sutat_draws_onece( _BFL1, p, 950, 250 + ty, 1 );
					
					ty += 60;
					
					_DYNBT_[35].locksn( i + 3, 0 );
					vbt = true;
				}
				
				if ( sd > -1 ) {
					var cn = 1/(smx+1);
					var shb = int(420 * cn);
					var hmx = 420 - shb;
					
					_DYNTXT_.fillRect( 930, 250 + (hmx * sd), 10, shb, 0xffffffff );
				} else {
					_DYNTXT_.fillRect( 930, 250, 10, 420, 0xffffffff );
				}
				
			}
			
			//_DYNBT_[35].visible = vbt;
			_DYNBT_[35].visible = true;
			_DYNBT_[99].visible = true;
			//_DYNBT_[45].visible = vbt;
			//_DYNBT_[45].setPos( 930, 0 );
			//_DYNBT_[45].fillRect( 0,0,350,720,0x88000000);
			//_DYNBT_[15].zoneAddal(czone1);
			
			_BFL1.freeImage();
		}
		
		/**
		 * ステータス表示 友軍拠点
		 * @param	aa=[]
		 * @param	ab=[]
		 * @param	sd=0.0
		 */
		function topside_sutat_draws_ar2(aa = [])
		{
			_DYNBT_[30].visible = false;
			_DYNBT_[35].visible = false;
			_DYNBT_[99].visible = false;
			
			if ( aa == -1 ) {
				_DYNTXT_.fillRect( 930, 30, 350, 200, 0x000000000 );
				_DYNTXT_.fillRect( 400, 120, 480, 600, 0x00000000 );
				return;
			}
			
			var ty, p, fm, lf;
			_BFL1.loadImages( 'bc_mini1' );
			
			if (aa.count > 0)
			{
				_draw_image_file_( _DYNTXT_, 930, 30, 'root_plate_01', ,, 0, 0, 350, 20 );
				
				ty = 0;
				
				//for ( var i = 0; i < aa.count; i ++ )
				for ( var i = 0; i < 3; i ++ )
				{
					//var aae = aa[pMmapview.PEXC[i]];
					var aae = aa[i];
					
					//if (aa[i] !== void)
					if (aae !== void)
					{
						_DYNTXT_.fillRect( 940, 50 + ty, 340, 20, 0xff000000 );
						_DYNTXT_.fillRect( 940, 70 + ty, 340, 40, 0xaa000000 );
						_DYNTXT_.fillRect( 930, 50 + ty, 10, 60, 0xff02ffbf );
						
						//_DYNTXT_.fillRect( 930+(3*i), 50 + ty, 10, 60, 0x8802ffbf );
						
						//p = uf.pDivi[aa[i]];
						p = uf.pDivi[aae];
						
						topside_sutat_draws_onece( _BFL1, p, 950, 50 + ty, 1 );
						
					}else{
						//_DYNTXT_.fillRect( 930, 50 + ty, 350, 60, 0x66000000 );
					}
					ty += 60;
				}
			}
			
			_BFL1.freeImage();
		}
		
		/**
		 * ステータス表示 敵軍拠点
		 * @param	aa=[]
		 * @param	ab=[]
		 */
		function topside_sutat_draws_em(aa = [], ac = 0, na = true)
		{
			_DYNBT_[35].visible = false;
			_DYNBT_[99].visible = false;
			
			if ( aa == -1 ) {
				_DYNBT_[30].visible = false;
				_DYNBT_[35].visible = false;
				_DYNBT_[99].visible = false;
				//_DYNTXT_.fillRect( 0, 30, 350, 200, 0x000000000 );
				_DYNTXT_.fillRect( 0, 30, 350, 690, 0x000000000 );
				return;
			}
			
			var vbt = false;
			
			_DYNTXT_.fillRect( 0, 30, 350, 690, 0x550000000 );
			
			var ty, p, fm;
			_BFL1.loadImages( 'bc_mini1' );
			
			_DYNBT_[30].locksnA( 2 );
			
			_draw_image_file_( _DYNTXT_, 0, 30, 'root_plate_01', ,, 0, 20, 350, 20 );
			
			if (aa.count > 0)
			{
				ty = 0;
				
				for ( var i = 0; i < 3; i ++ )
				{
					if (aa[i] !== void)
					{
						//_DYNTXT_.fillRect( 0, 50 + ty, 350, 60, 0x99000000 );
						_DYNTXT_.fillRect( 0, 50 + ty, 340, 20, 0xff000000 );
						_DYNTXT_.fillRect( 0, 70 + ty, 340, 40, 0xaa000000 );
						_DYNTXT_.fillRect( 340, 50 + ty, 10, 60, 0xfffe0000 );
						
						//_DYNTXT_.fillRect( 340+(3*i), 50 + ty, 10, 60, 0x88fe0000 );
					
						p = uf.eDivi[aa[i]];
						
						topside_sutat_draws_onece( _BFL1, p, 10, 50 + ty, 0 );
						
						_DYNBT_[30].locksn( i, 0 );
						vbt = true;
						
					}else{
						//_DYNTXT_.fillRect( 0, 50 + ty, 350, 60, 0x66000000 );
					}
					
					ty += 60;
				}
			}
			
			_draw_image_file_( _DYNTXT_, 0, 230, 'root_plate_01', ,, 0, 80, 350, 20 );
			
			_text_draw_super_( _DYNTXT_, 10, 232, "%2d".sprintf( uf.enemyReposPoint[ac] ), 0xffffff, 216 );
			
			//_DYNTXT_.fillRect( 0, 250, 350, 390, 0x55000000 );
			
			ty = 0;
			
			for ( var i = 0; i < 7; i ++ )
			{
				if ( uf.enemyReposDatas[ac][i] === void ) continue;
				
				_DYNTXT_.fillRect( 0, 250 + ty, 350, 20, 0xff000000 );
				_DYNTXT_.fillRect( 0, 270 + ty, 350, 40, 0xaa000000 );
					
				p = uf.eDivi[uf.enemyReposDatas[ac][i]];
				
				topside_sutat_draws_onece( _BFL1, p, 10, 250 + ty, 0 );
				
				ty += 60;
				
				_DYNBT_[30].locksn( i + 3, 0 );
				vbt = true;
			}
			
			//_DYNBT_[30].visible = vbt;
			_DYNBT_[30].visible = na;
			//_DYNBT_[45].visible = vbt;
			//_DYNBT_[45].setPos( 0, 0 );
			
			_BFL1.freeImage();
		}
		
		/**
		 * バックヤード表示リスト
		 * @param	n = void
		 * @param	sd = 0
		 */
		function topside_sutat_draw(n = void)
		{
			
			//if ( n === void ) {
				//_DYNTXT_.clear();
				//return;
			//}
			
			var ar = [], br = [];
			//var e = uf.quarters[n];
			var e = _getQuarters(n);
			
			//if ( dn != 1)
			//{
			for ( var i = 0; i < e.corps.count; i ++ )
			{
				ar.add(e.corps[i]);
			}
			//}
			
			//listcount
			if (e.party == 1) {
				
				listcountarr.clear();
				for ( var i = 0; i < 36; i ++ )
				{
					var p = uf.pDivi[i];
					//if ( p !== void && p.leader !== void && p.leader > -1 && p.pos === void )
					if ( p !== void && p.enable && p.pos === void )
					{
						listcountarr.add(i);
					}
				}
				
				var tls = [], con = 7, ppa = 0.0, ppaw = 0;
				
				if ( listcount > listcountarr.count - 7 ) {
					listcount = listcountarr.count - 7;	
				}
				
				if ( listcountarr.count < 7 ) {
					con = listcountarr.count;
					ppa = -1;
					ppaw = 7;
					listcount = 0;
				} else {
					con = 7;
					ppa = listcount / (listcountarr.count - 7);
					ppaw = listcountarr.count - 7;
				}
				
				for ( var i = 0; i < con; i ++ )
				{
					tls.add(listcountarr[i+listcount]);
				}
				
				topside_sutat_draws_ar(ar, tls, ppa, ppaw );
				_DYN_.setHelpLayers( %[storage:'help_rootmap02'] );
				
			} else if (e.party != 0) {
				topside_sutat_draws_em(ar, e.party );
				_DYN_.setHelpLayers( %[storage:'help_rootmap03'] );
			}
			
			
			/*
			listcountarr.clear();
			
			if (e.party == 1) {
			
				var st = 0;
				for ( var i = 0; i < 36; i ++ )
				{
					var p = uf.pDivi[i];
					
					//if ( p !== void && p.leader !== void && uf.quartersview.find(i)==-1 )
					if ( p !== void && p.leader !== void && p.pos === void )
					{
						listcountarr.add(i);
					
						st++;
						if (st >= 7) break;
					}
				}
			}
			*/

		}
		
		/**
		 * ユニットステータス反応領域
		 * @param	n
		 * @param	x
		 * @param	y
		 */
		function topmid_sutat_units(x,y,nxt)
		{
			var nx = -1;
			for ( var i = 0; i < nxt.count; i ++ )
			{
				if ( nxt[i] <= x && x < nxt[i] + 30 ) { nx = i; break; }
			}
			
			//dm( "topmid_sutat_units= %s < %s = %s".sprintf( x, nxt[0], nx));
			
			return nx;
		}
		
		/**
		 * ユニットステータス表示
		 * @param	m
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		function topmid_sutat_units1(m,x,y,z)
		{
			var nx = topmid_sutat_units(x,y,[20, 50, 80, 110, 140, 170]);
			
			var nu = void, nd = void;
			var qt = _getQuarters(tartgetCount);
			var du = ca2.get_Divs_Units(0);
			
			//if ( nx != -1 ) {
				//if ( m < 3) {
					//nu = du.Divis[qt.corps[m]].divo[nx];
				//} else {
					//nu = du.Divis[listcountarr[m - 3 + listcount]].divo[nx];
				//}
			//}
			if ( nx != -1 ) {
				if ( m < 3) {
					nd = du.Divis[qt.corps[m]];
					nu = nd.divo[nx];
				} else {
					nd = du.Divis[listcountarr[m - 3 + listcount]];
					nu = nd.divo[nx];
				}
			}
			
			if ( nu !== void ) {
				if ( unitstatsview_number != nu) {
					unitstatsview_number = nu;
					
					dm( "topmid_sutat_units= %s,%s [%s,%s,%s]".sprintf(m, unitstatsview_number,
						du.Units[unitstatsview_number].name,
						nd.leader,
						du.Units[unitstatsview_number].link.leader
						));
					ca3.layerUnitInfo(du.Units[unitstatsview_number], _DYNTXT_, 490, 160 );
				}
			} else {
				unitstatsview_number = -1;
				_DYNTXT_.fillRect( 400, 140, 480, 550, 0x00000000 );
			}
		}
		
		/**
		 * ユニットステータス表示　敵
		 * @param	m
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		function topmid_sutat_units2(m,x,y,z)
		{
			var nx = topmid_sutat_units(x,y,[10, 40, 70, 100, 130, 160]);
			
			var nu = void;
			var qt = _getQuarters(tartgetCount);
			var du = ca2.get_Divs_Units(1);
			
			if ( nx != -1 ) {
				if ( m < 3) {
					nu = du.Divis[qt.corps[m]].divo[nx];
				} else {
					nu = du.Divis[uf.enemyReposDatas[qt.party][m - 3]].divo[nx];
				}
			}
			
			if ( nu !== void ) {
				if ( unitstatsview_number != nu) {
					unitstatsview_number = nu;
					
					dm( "topmid_sutat_units= %s,%s,%s".sprintf(m, unitstatsview_number, du.Units[unitstatsview_number].name));
					ca3.layerUnitInfo(du.Units[unitstatsview_number], _DYNTXT_, 490, 160 );
				}
			} else {
				unitstatsview_number = -1;
				_DYNTXT_.fillRect( 400, 140, 480, 550, 0x00000000 );
			}
		}
		
		function topmid_sutat_units_leave()
		{
			dm( "topmid_sutat_units_leave");
			_DYNTXT_.fillRect( 400, 140, 480, 550, 0x00000000 );
			unitstatsview_number = void;
		}
		
		/**
		 * グループセレクタ
		 * @param	ix
		 */
		function on_unit_select_drug(ix)
		{	
			if ( ix < 3)
			{
				//var e = uf.quarters[tartgetCount];
				var e = _getQuarters(tartgetCount);
				
				var zond = [], zondt = [ 930,50, 930,110, 930,170 ];
				
				for ( var i = 0; i < 3; i ++ )
				{
					if ( e.corps[i] !== void )
					{
						zond.add( zondt[(i * 2)] );
						zond.add( zondt[(i * 2) + 1] );
					}
				}
				
				_DYN_.drugLayer.snapMode = 1;
				_DYN_.drugLayer.zoneClear();
				_DYN_.drugLayer.zoneAdda( zond, 350, 60, on_unit_select_drop );
				
				_DYN_.drugLayer.setCopyRect( _DYNTXT_, 930, 50 + (60 * ix), 350, 60 );
				//_DYN_.drugLayer.drugIconLayer.setPos( 930, 50 + (60 * ix) );
				_DYN_.drugLayer.drugIconLayer.colorRect( 0, 0, 350, 60, 0xff0000, 128 );
				
				//_DYN_.drugLayer.setLoadImage( "colorselect" );
				
				_DYN_.drugLayer.show2( ix, _DYNBT_[35], 15, 15 );
			}
			else {
				//_DYNBT_[35].onMouseLeave();
			}
			_DYN_.unlock();
		}
		
		
		/**
		 * グループセット
		 * @param	id
		 * @param	ix
		 */
		function on_unit_select_drop( id, ix )
		{

			
			
			//var e = uf.quarters[tartgetCount];
			var e = _getQuarters(tartgetCount);
			
			//dm( "item_drop(%d<->%d)+[%s,%s,%s]".sprintf( id, ix, e.corps[0], e.corps[1], e.corps[2] ));
			
			e.corps[id] <-> e.corps[ix];
			
			dm( "item_drop(%d<->%d)+[%s,%s,%s]".sprintf( id, ix, e.corps[0], e.corps[1], e.corps[2] ));
			
			//師団高速表示用データ更新
			//ca3.vbh_update_DiviData();
			
			//quartersからdivを更新
			//ca3.onUpdate_Quarters2Div();
			
			//ca3.onUpdate_Quarters_Backup();
			//ca3.onUpdate_Quarters2Div();
			
			//拠点ステータス
			//topside_sutat_draws_Quarters(tartgetCount);
				
			//topside_sutat_draw( tartgetCount );
			
			//_DYNBT_[40].onMouseLeave();
			
			//地上表示データ更新
			//pMmapview.setupUpdateDraw( 4 );
			
				
			//pMmapview.updateDraw();
			
			//師団高速表示用データ更新
			ca3.vbh_update_DiviData();
			
			//quartersからdivを更新
			ca3.onUpdate_Quarters2Div();
			
			//上段ステータス更新
			top_draw();
			
			//拠点ステータス更新
			topside_sutat_draws_Quarters(tartgetCount);	
			topside_sutat_draw( tartgetCount );
			
			//地上表示データ更新
			pMmapview.setupUpdateDraw(3, tartgetCount);
			
			//全体描写更新
			pMmapview.updateDraw();

			//反応領域更新
			if (_DYNBT_[20] !== void) pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
			
			_DYN_.unlock();
			
		}
		
		function on_unit_select_list(delta)
		{
			
			//_DYN_.lock();
			//var dd;
			//if(d<0) dd = 1; else dd = -1;
			//
			//listcount += dd;
			//if ( listcount < 0 ) listcount = 0;
			//if ( listcount > listcountarr.count - 7 ) listcount = listcountarr.count - 7;
			
			var n = listcount;
			
			if(delta>0) { n--; if( n < 0 ) n = 0; }
			if(delta<0) { n++; if( n > listcountarr.count - 7 ) n = listcountarr.count - 7; }
			if ( n != listcount ) kag.se[9].play( % [storage:'TMA1_click9h']);
			
			listcount = n;
			
			topside_sutat_draw( tartgetCount, 1 );
				
		}
		
		/**
		 * 師団表示切り替え scroll
		 * @param	delta
		 */
		function on_unit_select_list_scroll(y,h)
		{
			var n = listcount;
			var nmax = listcountarr.count - 7;
			
			var pa = listcount / nmax;
			var hx = 420 * (1 / (nmax + 1));
			if (hx < 50) hx = 50;
			var hh = h - hx;
			
			//_DYNTXT_.fillRect( 930, 250 + (hmx * sd), 10, shb, 0xffffffff );
			
			if (y > hh) { n = nmax; }
			else {
				n = int((y / hh) * nmax);
			}
			
			if ( listcount != n ) {
				kag.se[9].play( % [storage:'TMA1_click9h']);
				listcount = n;
				topside_sutat_draw( tartgetCount, 1 );
			}
		}
		
		function on_unit_map_adddel( m )
		{
			//kag.se[9].play( %[storage:'TMA1_click96'] );
			//kag.se[0].play( % [storage:'TMA1_se13'] );
			//kag.se[0].play( %[storage:'TMA1_se17'] );
			
			if ( m >= 3 ) {
				on_unit_map_add( m );
			}
			else if ( m < 3 ) { 
				on_unit_map_del( m );
			}
		}
		
		function on_unit_map_add( m )
		{
			
			if ( m >= 3  ) { 
				
				var e = _getQuarters(tartgetCount);
				tartgetCountTo = listcountarr[m - 3 + listcount];
				
				var tms = [], tmsc = 0;
				//tms.assignStruct(e.corps);
				//tms.add(tartgetCountTo);
				for ( var i = 0; i < 3; i ++ ) {
					if ( e.corps[i] !== void ) {
						tms.add(e.corps[i]);
						tmsc++;
					}
				}
				
				if ( !( uf.mapcache.pNow < uf.mapcache.pMax &&
					tmsc < 3 && uf.pDivi[tartgetCountTo].state == 0 )
					) {
						_DYN_.unlock();
						return;
					}
				
				kag.se[0].play( % [storage:'TMA1_se17'] );
					
				core2.standardTimer.Stop();
					
				_DYN_.lock();
				
				tms.add(tartgetCountTo);
				
				var ux, uy, xy = pMmapview.datas.chip[tartgetCount][2];
				
				//var xyn = pMmapview.getMoveLayersVec( tartgetCount );
				//var xy = pMmapview.datas.chip[tartgetCount][2];

				var xyz, xya = [];
				for ( var i = 0; i < 3; i ++ ) {
					//if ( tmsc == i ) xya.add( pMmapview.d3layer.ppCalc3r([ xy[0], xy[1], 150 ]) );
					if( tmsc == i ) xya.add( pMmapview.getMoveLayersVec(tartgetCount, -1) );
					else xya.add( pMmapview.getMoveLayersVec(tartgetCount, i) );
				}
				pMmapview.setMoveLayersExec( 1, tms, xya, pMmapview.getUnitFcs( tartgetCount, 1 ) );

				kag.process( , "*adddel_control" );
				
				var str;
				var i = e.corps.count;

				
				//for ( i = 0; i < e.corps.count; i++ ) {
					//
					//ux = xy[0] -1450 + pMmapview.UNITS_POS[i][0];
					//uy = xy[1] - 950 + pMmapview.UNITS_POS[i][1];
//
					//str = "(%d,%d,%d,0)".sprintf( ux, -uy, pMmapview.UNITS_POS[i][2]);
					//pMmapview.d3layer.movingLayer[i].beginMove( % [ time:500, path:str ] );
					//
				//}
				
				//var lays = pMmapview.d3layer.movingLayer[tartgetCountTo];
				//
				//lays.vecS = 0;	
					//
				//str = "(%d,%d,%d,%d)".sprintf( lays.vecX, lays.vecY, lays.vecZ, 300 );
				//lays.beginMove( % [ time:500, path:str, accel: 2 ] );
				//
				//lays.updateDraw = true;
				//lays.moveEndTrigerCallback = "adddel_control";
				//
				//
				//var lays = pMmapview.movingLayer[tmsc];
				var lays = pMmapview.movingLayer[tmsc];
				
				ux = xy[0] -1450 + pMmapview.UNITS_POS[tmsc][0];
				uy = xy[1] - 950 + pMmapview.UNITS_POS[tmsc][1];

				xyz = pMmapview.d3layer.ppCalc3r([
					xy[0] + pMmapview.UNITS_POS[tmsc][0],
					xy[1] + pMmapview.UNITS_POS[tmsc][1],
					pMmapview.UNITS_POS[tmsc][2]]);
			
				//pMmapview.d3layer.movingLayer[i].vecS = 300;	
					//
				//str = "(%d,%d,%d,0)".sprintf( ux, -uy, pMmapview.UNITS_POS[i][2]);
				//str = "(%d,%d,%d,%d)".sprintf( ux, -uy, pMmapview.UNITS_POS[i][2], 0 );
				//pMmapview.d3layer.movingLayer[i].beginMove( % [ time:500, path:str, accel: -2 ] );
				//
				//pMmapview.d3layer.movingLayer[i].updateDraw = true;
				//pMmapview.d3layer.movingLayer[i].moveEndTrigerCallback = "adddel_control";
				
				//lays.vecS = 200;
				
				str = "(%d,%d,%d,0)".sprintf( xyz[0], xyz[1], xyz[2] );	
				//str = "(%d,%d,%d,%d)".sprintf( ux, -uy, pMmapview.UNITS_POS[i][2], 0 );
				lays.beginMove( % [ time:300, path:str, accel: -2 ] );
				
				//lays.updateDraw = true;
				lays.endVisible = true;
				lays.moveEndTrigerCallback = "adddel_control";
				
				//地上表示データ更新
				pMmapview.setupUpdateDraw( 4, tartgetCount, 1 );
			
				//全体描写更新
				pMmapview.updateDraw();
			
				unit_map_add( tartgetCount, tartgetCountTo );
				
					//unit_map_add( m - 3 );
				
					dm( "movingLayer[%d]= %s,%s,%d => %s,%s,%s".sprintf(
						0,
						lays.vecX,
						lays.vecY,
						lays.visible,
						xyz[0], xyz[1], xyz[2]
					));
				
				//var str = "(%d,%d,%d,%d)".sprintf(
					//pMmapview.d3layer.CAMERA[0], pMmapview.d3layer.CAMERA[1], pMmapview.d3layer.CAMERA[2], pMmapview.d3layer.CAMERA[3] );
				//pMmapview.d3layer.beginMove( % [ time:300, path:str ] );
				//pMmapview.d3layer.moveEndTrigerCallback = "adddel_control";
				
			}
			else _DYN_.unlock();
		}
		
		function on_unit_map_del( m )
		{

			if ( m < 3 ) { 
				//unit_map_del( m );
				//} else _DYN_.unlock();
				
				var e = _getQuarters(tartgetCount);
				var p = uf.pDivi[e.corps[m]];
				tartgetCountTo = m;
				
				var tms = [], tmsc = 0;
				//tms.assignStruct(e.corps);
				//tms.add(tartgetCountTo);
				for ( var i = 0; i < 3; i ++ ) {
					tms.add(e.corps[i]);
					if ( e.corps[i] !== void ) tmsc++;
				}
				
				//if( !( e.corps.count <= 3 && p.state == 0 ) ) { _DYN_.unlock(); return; }
				if ( !( tmsc > 0 && p.state == 0 ) ) { _DYN_.unlock(); return; }
				
				kag.se[0].play( % [storage:'TMA1_se17'] );
				
				core2.standardTimer.Stop();
				
				_DYN_.lock();
				
				//var xyn = pMmapview.getMoveLayersVec( tartgetCount );
				var xya = [];
				for ( var i = 0; i < 3; i ++ ) {
					xya.add( pMmapview.getMoveLayersVec(tartgetCount, i) );
				}
				pMmapview.setMoveLayersExec( 1, tms, xya, pMmapview.getUnitFcs( tartgetCount, 1 ) );
				//pMmapview.setMoveLayers2( 1, e.corps, tartgetCount, 0 );

				kag.process( , "*adddel_control" );
				
				var lays = pMmapview.movingLayer[tartgetCountTo];
				
				lays.vecS = 0;	
				
				var xy = pMmapview.datas.chip[tartgetCount][2];
				var xyz = pMmapview.d3layer.ppCalc3r([ xy[0], xy[1], 150 ]);
			
				//var str = "(%d,%d,150,0)".sprintf( lays.vecX, lays.vecY, lays.vecZ, 200 );
				var str = "(%d,%d,150,0)".sprintf( xyz[0], xyz[1] );
				lays.beginMove( % [ time:300, path:str, accel: 2 ] );
				
				//lays.updateDraw = true;
				lays.endVisible = false;
				lays.moveEndTrigerCallback = "adddel_control";
					
				//地上表示データ更新
				pMmapview.setupUpdateDraw( 4, tartgetCount, 1 );
			
				//全体描写更新
				pMmapview.updateDraw();
			
				unit_map_del( tartgetCount, tartgetCountTo );
				
			}
			else _DYN_.unlock();
		}
		
			
		function unit_map_adddel_end()
		{
			
			var st = System.getTickCount();
			
			//pMmapview.targetLayer.visible = false;
			//System.inform("unit_map_adddel_end");
			
			//dm("unit_map_adddel_end.1 = 0" );
			
			for ( var i = 0; i < 3; i++ ) {
				pMmapview.movingLayer[i].visible = false;
				//pMmapview.movingLayer[i].update();
			}
			
			//dm("unit_map_adddel_end.2 = " + (System.getTickCount()- st) );
			
			//unit_map_add( tartgetCount, tartgetCountTo );
			//pMmapview.updateDraw();
			//
			
			//dm("unit_map_adddel_end.3 = " + (System.getTickCount() - st) );
			
			setupMapMode(3);
			//pMmapview.setupUpdateDraw( 3, tartgetCount, 1 );
			
			//dm("unit_map_adddel_end.4 = " + (System.getTickCount() - st) );
			
			//拠点ステータス
			topside_sutat_draws_Quarters(tartgetCount);
			topside_sutat_draw( tartgetCount );
			
			//_DYNBT_[35].onMouseLeave();
			
			core2.standardTimer.Play();
			
			pMmapview.targetLayer.visible = true;
			
			pMMenueview.onStackaction();
			
			_DYN_.unlock();
			
			//dm("unit_map_adddel_end.5 = " + (System.getTickCount()- st) );
		}
		
		//function unit_map_del_end()
		//{
			//for ( var i = 0; i < 3; i++ ) {
				//pMmapview.d3layer.movingLayer[i].visibleVec = false;
			//}
			//
			//setupMapMode(3);
			//
			//topside_sutat_draw( tartgetCount );
			//
			//if (_DYNBT_[45] !== void) {
				//for ( var i = 0; i < 12; i ++ ) _DYNBT_[45].locksn( i, 2 );
				//_DYNBT_[45].inFlag = -1;
				//_DYNBT_[45].targetBt.visible = false;
				//_DYNBT_[45].visible = false;
			//}
			//
			//_DYN_.unlock();
			//unit_map_del( tartgetCount, tartgetCountTo );
		//}
		
		function unit_map_add( n, nm )
		{
			//var e = uf.quarters[tartgetCount];
			var e = _getQuarters(n);
			//var nm = listcountarr[m + listcount];
			//var nm = tartgetCountTo;
			
			//if ( 	uf.mapcache.pNow < uf.mapcache.pMax &&
					//e.corps.count < 3 && listcountarr[m] !== void &&
					//uf.pDivi[nm].state == 0
					//)
			//if ( 	uf.mapcache.pNow < uf.mapcache.pMax &&
					//e.corps.count < 3 && uf.pDivi[nm].state == 0
					//)
			//{
				e.corps.add(nm);
				
				uf.pDivi[nm].state = 1;
				uf.pDivi[nm].force = 0;
				
				uf.mapcache.pNow++;
				
				ca3.onUpdate_Quarters2Div();
				
				//
				//setupMapMode(3);
				//
				//topside_sutat_draw( tartgetCount );
				
			//}
			
			//_DYN_.unlock();
			
			ca3.vbh_setDivi_voiceAdd(nm);
		}
		
		function unit_map_del( n, m )
		{	
		
			//var e = uf.quarters[tartgetCount];
			var e = _getQuarters(n);
			
			//if( e.corps.count<=3 && e.state == 0 )
			//{
				
				uf.pDivi[e.corps[m]].state = 0;
				uf.pDivi[e.corps[m]].force = 0;
				
				e.corps.erase(m);
				
				uf.mapcache.pNow--;
				
				ca3.onUpdate_Quarters2Div();
				
				//setupMapMode(3);
				//
				//topside_sutat_draw( tartgetCount );
			//}
			//
			//_DYN_.unlock();
		}
		
		
		
		function checkTrunLoop()
		{
			roc.onTrunEnd();
		}
		
	}
	
	dynamicbutton_object.screen.mainmap= new _SCREEN_TEMP_CLASS();
}
[endscript]
[endif]
[return]

*mainmap|&_STAGE_NAME[uf.game.stage]
[eval exp="pMMenueview.rootscreen = 'ScreenMainMap.ks'"]
[dynclear]
[pMMenueview_lock]

[if exp="core2.flipScreenEvent"]
[pMMenueview_hide]
[waittrig name="isloaded_callback"]
[endif]

*reStart

;初期値設定
;[eval exp='_DSCRLV= 0']
[mc_init_menuscreen name="mainmap"]
[dynsnaplayerback]
;[pMMenueview_hide]

[iscript]
	
	//データ更新
	ca3.vbh_update_Data();
	ca3.vbh_update_DiviData();
	pMmapview.d3layer.bImagesShift = uf.game.timeZone;
	
[endscript]

;各種スクリーン初期化

;右クリックタグを追加
[dynrclick target='*sub_back']

;画像ロード
;[dynsnaplayertmpo_draw layer="back"]

;テキスト描写

;表示部
;[dynshow]

[layopt layer=0 page=back visible=true]
[layopt layer=1 page=back visible=false]
[layopt layer=2 page=back visible=false]
[layopt layer=3 page=back visible=false]

[image layer=0 storage='root_ui_top' left=0 top=0 page=back]
;[eval exp='_draw_image_file_( _DYN_.baseLayer, 0, 0, "root_ui_top" )']

;[dynbuttonedit no=99 x=500 y=100 w=200 h=20 fsize=14]

;;[dynbutton no=5 x=10 y=600 graphic='root_bt07' hint=''	target=*sub_trunexec	clicksebuf=1]

;[dynbutton no = 20 x = 60 y = 650 graphic = 'extra_btBGM04' exp = '_DSCR.focusLockMode()' clicksebuf = 1]
;[dynbutton no = 23 x = 10 y = 650 graphic = 'extra_btBGM05' exp = '_DSCR.infoViewMode()' clicksebuf = 1]

;;[dynbutton no=23 x=10 y=650 graphic='extra_btBGM05' exp='roc.onEasyMapSkip()' clicksebuf=1]

;[dynbutton no=24 x=1000 y=650 graphic='extra_btBGM03' exp='_DSCR.onScreenSemiAutoTrun(0)' clicksebuf=1]
;[dynbutton no=7 x=1000 y=650 graphic='title_bt_exit' hint='終了'	exp='_DSCR.onScreenMapFiled(1)'	clicksebuf=1]
;[dynbutton no=8 x=900  y=650 graphic='title_bt_exit' hint='終了'	exp='_DSCR.onScreenMapFiled(2)'	clicksebuf=1]
;[dynbutton no=9 x=800  y=650 graphic='title_bt_exit' hint='終了'	exp='_DSCR.testmv()'	clicksebuf=1]

;[dynbutton no = 25 x = 1230 y = 50  graphic = 'extra_btBGM04' exp = '_DSCR.unit_map_del()' clicksebuf = 1]
;[dynbutton no = 26 x = 1230 y = 100 graphic = 'extra_btBGM04' exp = '_DSCR.unit_map_del()' clicksebuf = 1]
;[dynbutton no = 27 x = 1230 y = 150 graphic = 'extra_btBGM04' exp = '_DSCR.unit_map_del()' clicksebuf = 1]

;[dynbuttonm2 no=50 x=0 y=0 w=1280 h=700 graphic='bigtarget' expd='_DSCR.viewRoomStatasEnter' exp2='_DSCR.viewRoomStatasEnterZ' onenter="" onwheel=""]
;[dynbuttonm no=45 graphic='target350x60' zomed='_DSCR.czone1' zw=350 zh=60 sw=3 expd='_DSCR.unit_map_add' expdd='_DSCR.unit_map_del' expg='_DSCR.item_drug' onwheel="_DSCR.units_select_wheel(delta)"]

;[dynbuttonm no=44 graphic='target30x30' zomed='_DSCR.czone2' zw=30 zh=30 expd='' expg='']

;[dynbuttonm no = 30 zomed = '_DSCR.czone2' zw = 30 zh = 30 sw = 3 onenter = '']

;[dynbuttonm no=45 graphic='target350x60' zomed='_DSCR.czone1' zw=350 zh=60 sw=3 expd='_DSCR.on_unit_map_add' expdd='_DSCR.on_unit_map_del' expg='_DSCR.on_unit_select_drug' onwheel='_DSCR.on_unit_select_list(delta)']
;[dynbuttonm no=45 zomed='_DSCR.czone1' zw=350 zh=60 sw=3 expd='_DSCR.on_unit_map_add' expdd='_DSCR.on_unit_map_del' expg='_DSCR.on_unit_select_drug' onwheel='_DSCR.on_unit_select_list(delta)']

[dynbuttonm no=35 zomed='_DSCR.czone1' zw=350 zh=60 sw=3 expd='_DSCR.on_unit_map_adddel' expg='_DSCR.on_unit_select_drug' onwheel='_DSCR.on_unit_select_list(delta)' onenter2='_DSCR.topmid_sutat_units1' onleave='_DSCR.topmid_sutat_units_leave()']
[dynbuttonm no=30 zomed='_DSCR.czone2' zw=350 zh=60 sw=3 onenter2='_DSCR.topmid_sutat_units2' onleave='_DSCR.topmid_sutat_units_leave()']

;[dynbuttonee no=45 x=0 y=0 w=350 h=720 ]

;[dynbuttonm no=44 graphic='target30x30' zomed='_DSCR.czone2' zw=30 zh=30 expd='' expg='']


;[dynbuttonee no = 30 x = 0 y = 600 w = 256 h = 110 exp = '_DSCR.onMoveMiniMapFiled(delta)' expu = 'pMmapview.d3layer.updateClipDraw(_DYNBT_[20])']

;[dynbuttonee no=40 x=100 y=100 w=20 h=30 color=0xff00ff00 expd='_DSCR.grp_select(0)' clicksebuf=1 ]

;[dynbuttonm2 no=50 x=0 y=0 w=1280 h=700 graphic='bigtarget' expd='_DSCR.viewRoomStatasEnter' exp2='_DSCR.viewRoomStatasEnterZ' onenter="" onwheel=""]
[dynbuttonm3 no=20 x=0 y=0 w=1280 h=700 onenter='_DSCR.viewRoomEnter' onleave='_DSCR.viewRoomLeave' expd='_DSCR.viewRoomStatasEnter' ]

[dynbuttoneed no=10 x=0 y=0 w=1280 h=700 exp='_DSCR.onMoveMapFiled(delta)' expd='_DSCR.onScreenMapMVFiledAll(delta)' onwheel='_DSCR.onMoveMapFiledW(delta)' expu='_DSCR.onMoveMapFiledup(delta)']

;[dynbuttonmex no=15 expg='' expdd='' onenter='_DSCR.topside_sutat_draw_target' onwheel="_DSCR.units_select_wheel(delta)"]
;[dynbuttonm no=60 graphic='target350x60' zomed='_DSCR.czone1' zw=350 zh=60 sw=10 expg='_DSCR.item_drug' expdd='_DSCR.rejectChars' onwheel="_DSCR.units_select_wheel(delta)"]

[dynbuttonscr no=99 x=930 y=250 w=10 h=420 exp='_DSCR.on_unit_select_list_scroll(delta)']

[pMmapview_show page=back ]

[stoptrans]

[dynhelper storage='help_rootmap01']

;音楽再生
;[bgm storage=&f.SlgBGM]

[dynbtn_false]
;[dyntexts visible=false]
[dyntexts visible=true]
[dynshow]
;[pMMenueview_show page=back]
[pMMenueview_btn lock=0]
[pMMenueview_dropfront]
[pMMenueview_update]

[iscript]
	
	//pMmapview.d3layer.onTimerFrameReset();

	pMmapview.getCameraBackup();
	//pMmapview.updateDraw();
	
	core2.standardTimerCallback = pMmapview.onTimerEventCall;

	//pMmapview.updateDraw();
	
	_DSCR.setupMapModeTop(true);
	
[endscript]

[trans method=crossfade time=300]
[wt canskip=false]

[iscript]
	
	_DYNBT_[35].visible = false;
	_DYNBT_[30].visible = false;
	_DYNBT_[99].visible = false;
	//_DYNBT_[45].visible = false;
	
	pMmapview.d3layer.updateClipDraw(_DYNBT_[20]);
	
[endscript]

;[dyntexts_fade]
[dynbtn_true]

*pre_dialog_control
[if exp="pMMenueview.nextDialogshowPre()"]
[waittrig name="dialog_control"]
[eval exp='pMMenueview.status_update()']
[jump target="*pre_dialog_control"]
[endif]

[eval exp='pMMenueview.onStackaction()']

[eval exp='roc.onViewMapRoot()']
*onViewMapRootReturnBack

[eval exp='pMMenueview.status_update()']

[jump target="*dialog_control"]
;[dynunlock key=1]
;[pMMenueview_unlock]
;[menulevel level = 1]
*onEventThrow
[s]

;実行部メニュー
*sub_back
[iscript]
	if ( pMmapview.moveMode != 0 ) _DSCR.setupMapModeTop();
[endscript]
[s]

*sub_trunexec
[iscript]

	_DSCR.setupMapModeTop();
	core2.standardTimer.Stop();
	
	_DYN_.copyTempLayer(%[ layer:pMmapview.baseLayer ]);
	kag.fore.base.piledCopy( 0, 0, kag.fore.base, 0, 0, 1280, 720);
	
	pMmapview.baseLayer.enabled = false;
	
	pMmapview.setCameraBackup();
	
	pMmapview.enemyMove.enemyMoveSetup([2]);
	
	tf.turnLog = [];
	
	roc.onTrunExec();
	
[endscript]
[s]

*sub_jump
[pMMenueview_lock]
[dynhide]
[iscript]

	_DSCR.setupMapModeTop();
	core2.standardTimer.Stop();

	_DYN_.copyTempLayer(%[ blur:2, layer:pMmapview.baseLayer ]);
	kag.fore.base.piledCopy( 0, 0, kag.fore.base, 0, 0, 1280, 720);
	
	//pMmapview.baseLayer.enabled = false;
	
[endscript]
[eval exp="pMmapview.setCameraBackup()"]
[pMmapview_hide]
[pMMenueview_lock]
[pMMenueview_jump]
[s]

*sub_jump2
[pMMenueview_lock]
[dynhide]
[iscript]

	_DSCR.setupMapModeTop();
	//core2.timerEventCaller.Stop2();
	core2.standardTimer.Stop();
	
	//_DYN_.copyTempLayer(%[ layer:pMmapview.baseLayer, color:0xff00ff00 ]);
	
	//背景だけコピーする
	//_DYN_.tempSnapLayer.setImageSize(960, 720);
	//_DYN_.tempSnapLayer.copyRect( 0, 0, pMmapview.floorLayer, -pMmapview.floorLayer.left, -pMmapview.floorLayer.top, 960, 720 );
	//_DYN_.tempSnapLayer.colorRect( 0, 0, 960, 720, 0x000000, 128 );
	
	kag.fore.base.piledCopy( 0, 0, kag.fore.base, 0, 0, 1280, 720);
	
	//pMmapview.baseLayer.enabled = false;
	
[endscript]
[eval exp="pMmapview.setCameraBackup()"]
[pMmapview_hide]
[pMMenueview_lock]
[s]

*subtrun_jump
[dynhide]
[iscript]

	_DSCR.setupMapModeTop();
	//core2.timerEventCaller.Stop2();
	core2.standardTimer.Stop();
	
	//_DYN_.copyTempLayer(%[ blur:2, gamma:128, layer:pMmapview.baseLayer ]);
	_DYN_.copyTempLayer(%[ blur:2, layer:pMmapview.baseLayer ]);
	
	kag.fore.base.piledCopy( 0, 0, kag.fore.base, 0, 0, 960, 720);
	
	//pMmapview.baseLayer.enabled = false;
	
	//roc.onTrunStart();
	
[endscript]
[eval exp="pMmapview.setCameraBackup()"]
[pMmapview_hide]
[pMMenueview_jump]
[s]

;実行部処理

;コントローラ
*view_control
[waittrig name="view_control"]
[iscript]
	core2.standardTimer.Play();
[endscript]
[dynunlock key=1]
[pMMenueview_unlock]
[s]

*viewzoom_control
[waittrig name="viewzoom_control"]
[iscript]
	_DSCR.onScreenMapMVFiledAll_end();
[endscript]
[dynunlock key=1]
[pMMenueview_unlock]
[s]


*view_control_not
;[waittrig name="pMmapview" cond="!pMmapview.notZommed"]
[dynunlock key=1]
[pMMenueview_unlock]
[iscript]
	_DSCR.mapViewControlEnd();
[endscript]
[s]

*dialog_control
[if exp="pMMenueview.nextDialogshow(0)"]
[waittrig name="dialog_control"]
[eval exp='pMMenueview.status_update()']
[jump target="*dialog_control"]
[else]
[dynunlock key=1]
[pMMenueview_unlock]
[menulevel level=1]
[endif]
;[wait time=500]

[eval exp="core2.standardTimer.Play(100,1)"]
;セーブポイントでスナップしている情報を上書き。
[eval exp="kag.pcflags.bgm= kag.bgm.store()" ]
[s]

*moved_control
[waittrig name = "moved_control"]
[iscript]
	_DSCR.set_add_map_units_end_check();
	_DYNBT_[20].onMouseEnter();
[endscript]
[dynunlock key=1]
[pMMenueview_unlock]
[s]

*adddel_control
[waittrig name="adddel_control"]
;[eval exp = "pMmapview.movingLayer[0].visible = false;"]
;[wait time = 100]
[iscript]
	//_DSCR.set_add_map_units_end_check();
	//_DYNBT_[20].onMouseEnter();	
	_DSCR.unit_map_adddel_end();
[endscript]
[dynunlock key=1]
[pMMenueview_unlock]
[s]

*battle_control
[eval exp="kag.se[0].play( %[storage:'TMA1_se11'] )"]
[eval exp="core2.standardTimer.Stop()"]
[dynclearlayerback]
;[trans method=crossfade time=800]
[stoptrans]
[eval exp="_DYN_.set_now_Screen('battlemode')"]
[eval exp="kag.back.base.fillRect(0,0,1280,720,0xff000000)"]
[eval exp="kag.quickSaveKey= false"]
[eval exp="core2.setEfxReset()"]
[layopt layer=0 page=back visible=false]
[layopt layer=1 page=back visible=false]
[layopt layer=2 page=back visible=false]
[layopt layer=3 page=back visible=false]
[trans method=mosaic time=1000]
[wt canskip=false]
[stoptrans]
[dynhide]
[dynclear]
[pMMenueview_hide]
[eval exp="pMmapview.setCameraBackup()"]
[pMmapview_hide]
[menulevel level=0]
[dynend]
[eval exp="pMmapview.freeImage()"]
[jump storage="battleMain.ks"]
[s]

*jumpRootViewCallback
[eval exp="core2.standardTimer.Stop()"]
[dynclearlayerback]
[stoptrans]
[eval exp="_DYN_.set_now_Screen('avgmode')"]
[eval exp="kag.back.base.fillRect(0,0,1280,720,0xff000000)"]
[eval exp="kag.quickSaveKey= false"]
[eval exp="core2.setEfxReset()"]
[layopt layer=0 page=back visible=false]
[layopt layer=1 page=back visible=false]
[layopt layer=2 page=back visible=false]
[layopt layer=3 page=back visible=false]
[trans method=crossfade time=500]
[wt canskip=false]
[stoptrans]
[dynhide]
[dynclear]
[pMMenueview_hide]
[eval exp="pMmapview.setCameraBackup()"]
[pMmapview_hide]
[menulevel level=0]
[dynend]
[eval exp="pMmapview.freeImage()"]
[pMMenueview_jump]
[s]

*returnsubmenu
[eval exp="core2.standardTimer.Play()"]
[pMMenueview_unlock]
[s]

;----------------------------------------------
*title_exit
[eval exp="kag.closeByScript(%[ask:true]);"]
[s]