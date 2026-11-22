-- SPDX-License-Identifier: MPL-2.0
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, obtain one at https://mozilla.org/MPL/2.0/.
--[[
	RiftUI: a dock-style hub library for sUNC executors.

	local Rift = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naymmmm/riftui/main/public/Loader.luau"))()

	xpcall(function()
		local Hub = Rift:CreateHub({ Name = "Rift Hub", Subtitle = "Baseplate" })
		local Combat = Hub:Tab({ Name = "Combat", Icon = "crosshair" })
		local Aim = Combat:Section({ Name = "Aim Assist" })
		Aim:Toggle({ Name = "Enabled", Flag = "AimEnabled", Default = true, Callback = function(on) end })
	end, Rift.HandleError)

	Tabs are tiles in a slim toolbar at the bottom of the screen. Clicking a tile opens its
	panel in the middle of the screen; clicking anywhere else folds it back into the tile.
	Sections can be pinned to stay on screen while the toolbar is hidden.
]]

local ICON_INDEX = {
	Version = "1.62.0",
	Cell = 48,
	Inset = 2,
	PerRow = 21,
	PerSheet = 441,
	Sheets = 5,
	Names = "a-arrow-down,a-arrow-up,a-large-small,accessibility,activity,activity-square,ad,air-vent,airplay,alarm-check,alarm-clock,alarm-clock-check,alarm-clock-minus,alarm-clock-off,alarm-clock-plus,alarm-minus,alarm-plus,alarm-smoke,album,alert-circle,alert-octagon,alert-triangle,align-center,align-center-horizontal,align-center-vertical,align-end-horizontal,align-end-vertical,align-horizontal-distribute-center,align-horizontal-distribute-end,align-horizontal-distribute-start,align-horizontal-justify-center,align-horizontal-justify-end,align-horizontal-justify-start,align-horizontal-space-around,align-horizontal-space-between,align-justify,align-left,align-right,align-start-horizontal,align-start-vertical,align-vertical-distribute-center,align-vertical-distribute-end,align-vertical-distribute-start,align-vertical-justify-center,align-vertical-justify-end,align-vertical-justify-start,align-vertical-space-around,align-vertical-space-between,ambulance,ampersand,ampersands,amphora,anchor,angle,angry,annoyed,antenna,anvil,aperture,app-window,app-window-mac,apple,archive,archive-restore,archive-x,area-chart,armchair,armenian-dram,arrow-big-down,arrow-big-down-dash,arrow-big-left,arrow-big-left-dash,arrow-big-right,arrow-big-right-dash,arrow-big-up,arrow-big-up-dash,arrow-down,arrow-down-0-1,arrow-down-01,arrow-down-1-0,arrow-down-10,arrow-down-a-z,arrow-down-az,arrow-down-circle,arrow-down-from-line,arrow-down-left,arrow-down-left-from-circle,arrow-down-left-from-square,arrow-down-left-square,arrow-down-narrow-wide,arrow-down-right,arrow-down-right-from-circle,arrow-down-right-from-square,arrow-down-right-square,arrow-down-square,arrow-down-to-dot,arrow-down-to-line,arrow-down-up,arrow-down-wide-narrow,arrow-down-z-a,arrow-down-za,arrow-left,arrow-left-circle,arrow-left-from-line,arrow-left-right,arrow-left-square,arrow-left-to-line,arrow-right,arrow-right-circle,arrow-right-from-line,arrow-right-left,arrow-right-square,arrow-right-to-line,arrow-up,arrow-up-0-1,arrow-up-01,arrow-up-1-0,arrow-up-10,arrow-up-a-z,arrow-up-az,arrow-up-circle,arrow-up-down,arrow-up-from-dot,arrow-up-from-line,arrow-up-left,arrow-up-left-from-circle,arrow-up-left-from-square,arrow-up-left-square,arrow-up-narrow-wide,arrow-up-right,arrow-up-right-from-circle,arrow-up-right-from-square,arrow-up-right-square,arrow-up-square,arrow-up-to-line,arrow-up-wide-narrow,arrow-up-z-a,arrow-up-za,arrows-up-from-line,asterisk,asterisk-square,astroid,at-sign,atom,audio-lines,audio-lines-off,audio-lines-x,audio-waveform,avocado,award,axe,axis-3-d,axis-3d,azerbaijani-manat,baby,backpack,bacon,badge,badge-alert,badge-cent,badge-check,badge-dollar-sign,badge-euro,badge-help,badge-indian-rupee,badge-info,badge-japanese-yen,badge-minus,badge-percent,badge-plus,badge-pound-sterling,badge-question-mark,badge-russian-ruble,badge-swiss-franc,badge-turkish-lira,badge-x,baggage-claim,ball-wave,balloon,ban,banana,bandage,bangladeshi-taka,banknote,banknote-arrow-down,banknote-arrow-up,banknote-check,banknote-x,bar-chart,bar-chart-2,bar-chart-3,bar-chart-4,bar-chart-big,bar-chart-horizontal,bar-chart-horizontal-big,barcode,barrel,baseline,bath,battery,battery-charging,battery-full,battery-low,battery-medium,battery-plus,battery-warning,beaker,bean,bean-off,bed,bed-double,bed-single,beef,beef-off,beer,beer-off,belarusian-ruble,bell,bell-check,bell-dot,bell-electric,bell-minus,bell-off,bell-plus,bell-ring,between-horizonal-end,between-horizonal-start,between-horizontal-end,between-horizontal-start,between-vertical-end,between-vertical-start,biceps-flexed,bike,binary,binoculars,biohazard,bird,birdhouse,bitcoin,blend,blender,blinds,blocks,bluetooth,bluetooth-connected,bluetooth-off,bluetooth-searching,bold,bolt,bomb,bone,bone-fracture,book,book-a,book-alert,book-audio,book-bookmark,book-check,book-copy,book-dashed,book-down,book-headphones,book-heart,book-image,book-key,book-lock,book-marked,book-minus,book-open,book-open-check,book-open-text,book-plus,book-search,book-template,book-text,book-type,book-up,book-up-2,book-user,book-x,bookmark,bookmark-check,bookmark-minus,bookmark-off,bookmark-plus,bookmark-x,boom-box,bot,bot-message-square,bot-off,bottle-wine,bow-arrow,box,box-select,boxes,braces,brackets,brain,brain-circuit,brain-cog,brain-off,brick-wall,brick-wall-fire,brick-wall-shield,bridge,briefcase,briefcase-business,briefcase-conveyor-belt,briefcase-medical,briefcase-plus,bring-to-front,broccoli,broom,broom-sparkles,brush,brush-cleaning,bubbles,bug,bug-off,bug-play,building,building-2,building-complex,building-complex-plus,bus,bus-front,cable,cable-car,cake,cake-slice,calculator,calendar,calendar-1,calendar-arrow-down,calendar-arrow-up,calendar-check,calendar-check-2,calendar-chevrons-left,calendar-chevrons-right,calendar-clock,calendar-cog,calendar-days,calendar-fold,calendar-heart,calendar-minus,calendar-minus-2,calendar-off,calendar-plus,calendar-plus-2,calendar-range,calendar-search,calendar-sync,calendar-x,calendar-x-2,calendars,camera,camera-off,can,can-soda,candlestick-chart,candy,candy-cane,candy-off,cannabis,cannabis-off,captions,captions-off,car,car-battery,car-front,car-taxi-front,caravan,card-sim,carrot,carton,carton-off,case-lower,case-sensitive,case-upper,cassette-tape,cast,castle,cat,cctv,cctv-off,certificate,chart-area,chart-bar,chart-bar-big,chart-bar-decreasing,chart-bar-increasing,chart-bar-stacked,chart-candlestick,chart-column,chart-column-big,chart-column-decreasing,chart-column-increasing,chart-column-stacked,chart-gantt,chart-line,chart-network,chart-no-axes-column,chart-no-axes-column-decreasing,chart-no-axes-column-increasing,chart-no-axes-combined,chart-no-axes-gantt,chart-pie,chart-scatter,chart-spline,check,check-check,check-circle,check-circle-2,check-line,check-square,check-square-2,chef-hat,cherry,chess-bishop,chess-king,chess-knight,chess-pawn,chess-queen,chess-rook,chevron-down,chevron-down-circle,chevron-down-square,chevron-first,chevron-last,chevron-left,chevron-left-circle,chevron-left-square,chevron-right,chevron-right-circle,chevron-right-square,chevron-up,chevron-up-circle,chevron-up-square,chevrons-down,chevrons-down-up,chevrons-left,chevrons-left-right,chevrons-left-right-ellipsis,chevrons-right,chevrons-right-left,chevrons-up,chevrons-up-down,church,cigarette,cigarette-off,circle,circle-alert,circle-arrow-down,circle-arrow-left,circle-arrow-out-down-left,circle-arrow-out-down-right,circle-arrow-out-up-left,circle-arrow-out-up-right,circle-arrow-right,circle-arrow-up,circle-check,circle-check-big,circle-chevron-down,circle-chevron-left,circle-chevron-right,circle-chevron-up,circle-chevrons-down,circle-chevrons-left,circle-chevrons-right,circle-chevrons-up,circle-dashed,circle-dashed-check,circle-divide,circle-dollar-sign,circle-dot,circle-dot-dashed,circle-ellipsis,circle-equal,circle-euro,circle-fading-arrow-up,circle-fading-play,circle-fading-plus,circle-gauge,circle-help,circle-minus,circle-off,circle-parking,circle-parking-off,circle-pause,circle-percent,circle-pile,circle-play,circle-plus,circle-pound-sterling,circle-power,circle-question-mark,circle-slash,circle-slash-2,circle-slashed,circle-small,circle-star,circle-stop,circle-user,circle-user-round,circle-x,circuit-board,citrus,clapperboard,clef-alto,clef-bass,clef-treble,clipboard,clipboard-check,clipboard-clock,clipboard-copy,clipboard-edit,clipboard-list,clipboard-minus,clipboard-paste,clipboard-pen,clipboard-pen-line,clipboard-plus,clipboard-signature,clipboard-type,clipboard-x,clock,clock-1,clock-10,clock-11,clock-12,clock-2,clock-3,clock-4,clock-5,clock-6,clock-7,clock-8,clock-9,clock-alert,clock-arrow-down,clock-arrow-left,clock-arrow-right,clock-arrow-up,clock-check,clock-fading,clock-plus,closed-caption,cloud,cloud-alert,cloud-backup,cloud-check,cloud-cog,cloud-download,cloud-drizzle,cloud-fog,cloud-hail,cloud-lightning,cloud-moon,cloud-moon-rain,cloud-off,cloud-rain,cloud-rain-wind,cloud-snow,cloud-sun,cloud-sun-rain,cloud-sync,cloud-upload,cloudy,clover,club,code,code-2,code-square,code-xml,coffee,cog,coins,columns,columns-2,columns-3,columns-3-cog,columns-4,columns-settings,combine,command,compass,component,computer,concierge-bell,cone,construction,contact,contact-2,contact-round,container,contrast,cookie,cooking-pot,copy,copy-check,copy-minus,copy-plus,copy-slash,copy-x,copyleft,copyright,corner-down-left,corner-down-right,corner-left-down,corner-left-up,corner-right-down,corner-right-up,corner-up-left,corner-up-right,cpu,cpu-ai,creative-commons,credit-card,credit-card-check,credit-card-minus,credit-card-plus,credit-card-reader,credit-card-x,croissant,crop,cross,crosshair,crown,cuboid,cup-soda,cupcake,curly-braces,currency,cylinder,dam,database,database-arrow-down,database-arrow-up,database-backup,database-check,database-minus,database-plus,database-search,database-x,database-zap,decimals-arrow-left,decimals-arrow-right,delete,dessert,diameter,diamond,diamond-minus,diamond-percent,diamond-plus,dice-1,dice-2,dice-3,dice-4,dice-5,dice-6,dices,diff,disc,disc-2,disc-3,disc-album,divide,divide-circle,divide-square,dna,dna-off,dock,dog,dollar-sign,dome,donut,door-closed,door-closed-cog,door-closed-locked,door-closed-package,door-open,door-stairwell,dot,dot-square,download,download-cloud,drafting-compass,drama,drill,drone,droplet,droplet-off,droplets,drum,drumstick,dumbbell,ear,ear-off,earth,earth-lock,eclipse,edit,edit-2,edit-3,egg,egg-fried,egg-off,eighth-note,eighth-notes,eject,ellipse,ellipsis,ellipsis-vertical,emirati-dirham,engine,equal,equal-approximately,equal-approximately-not,equal-not,equal-square,eraser,ethernet-port,euro,ev-charger,expand,external-link,eye,eye-closed,eye-dashed,eye-off,face-angry,face-expressionless,face-grinning,face-neutral,face-slightly-frowning,face-slightly-smiling,face-slightly-smiling-plus,factory,fan,fast-forward,faucet,feather,fence,ferris-wheel,file,file-archive,file-audio,file-audio-2,file-axis-3-d,file-axis-3d,file-badge,file-badge-2,file-bar-chart,file-bar-chart-2,file-box,file-braces,file-braces-corner,file-chart-column,file-chart-column-increasing,file-chart-line,file-chart-pie,file-check,file-check-2,file-check-corner,file-clock,file-code,file-code-2,file-code-corner,file-cog,file-cog-2,file-diff,file-digit,file-down,file-edit,file-exclamation-point,file-headphone,file-heart,file-image,file-input,file-json,file-json-2,file-key,file-key-2,file-line-chart,file-lock,file-lock-2,file-minus,file-minus-2,file-minus-corner,file-music,file-output,file-pen,file-pen-line,file-pie-chart,file-play,file-plus,file-plus-2,file-plus-corner,file-question,file-question-mark,file-scan,file-search,file-search-2,file-search-corner,file-signal,file-signature,file-sliders,file-spreadsheet,file-stack,file-symlink,file-terminal,file-text,file-type,file-type-2,file-type-corner,file-up,file-user,file-video,file-video-2,file-video-camera,file-volume,file-volume-2,file-warning,file-x,file-x-2,file-x-corner,files,film,filter,filter-x,fingerprint,fingerprint-pattern,fire-extinguisher,fish,fish-off,fish-symbol,fishing-hook,fishing-rod,flag,flag-off,flag-triangle-left,flag-triangle-right,flame,flame-kindling,flashlight,flashlight-off,flask-conical,flask-conical-off,flask-round,flip-horizontal,flip-horizontal-2,flip-vertical,flip-vertical-2,flower,flower-2,focus,fold-horizontal,fold-vertical,folder,folder-archive,folder-bookmark,folder-check,folder-clock,folder-closed,folder-code,folder-cog,folder-cog-2,folder-dot,folder-down,folder-edit,folder-git,folder-git-2,folder-heart,folder-input,folder-kanban,folder-key,folder-lock,folder-minus,folder-open,folder-open-dot,folder-output,folder-pen,folder-plus,folder-root,folder-search,folder-search-2,folder-symlink,folder-sync,folder-tree,folder-up,folder-user,folder-users,folder-x,folders,footprints,fork-knife,fork-knife-crossed,forklift,form,form-input,forward,frame,frown,fuel,fullscreen,function-square,funnel,funnel-plus,funnel-x,galaxy,gallery-horizontal,gallery-horizontal-end,gallery-thumbnails,gallery-vertical,gallery-vertical-end,gamepad,gamepad-2,gamepad-directional,gantt-chart,gantt-chart-square,gap-horizontal,gap-vertical,gauge,gauge-circle,gavel,gem,georgian-lari,germ,germ-off,ghost,gift,git-branch,git-branch-minus,git-branch-plus,git-commit,git-commit-horizontal,git-commit-vertical,git-compare,git-compare-arrows,git-fork,git-graph,git-merge,git-merge-conflict,git-pull-request,git-pull-request-arrow,git-pull-request-closed,git-pull-request-create,git-pull-request-create-arrow,git-pull-request-draft,glass-water,glasses,globe,globe-2,globe-check,globe-code,globe-lock,globe-off,globe-x,goal,gpu,grab,graduation-cap,grape,graph-hub,graph-star,grid,grid-2-x-2,grid-2-x-2-check,grid-2-x-2-plus,grid-2-x-2-x,grid-2x2,grid-2x2-check,grid-2x2-plus,grid-2x2-x,grid-3-x-3,grid-3x2,grid-3x3,grip,grip-horizontal,grip-vertical,groceries,group,guitar,guitar-electric,half-note,ham,hamburger,hammer,hand,hand-coins,hand-fist,hand-grab,hand-heart,hand-helping,hand-metal,hand-platter,handbag,handle-bottom-right,handshake,hard-drive,hard-drive-download,hard-drive-upload,hard-hat,hash,hat-glasses,haze,hd,hdmi-port,heading,heading-1,heading-2,heading-3,heading-4,heading-5,heading-6,headphone-off,headphones,headset,heart,heart-crack,heart-handshake,heart-minus,heart-off,heart-plus,heart-pulse,heart-x,heater,helicopter,help-circle,helping-hand,hexagon,highlighter,hiking-stick,history,hockey-stick,home,hop,hop-off,hospital,hot-air-balloon,hotel,hourglass,hourglass-cog,house,house-cog,house-heart,house-plug,house-plus,house-wifi,houses,ice-cream,ice-cream-2,ice-cream-bowl,ice-cream-cone,id-card,id-card-lanyard,image,image-down,image-minus,image-off,image-play,image-plus,image-up,image-upscale,images,import,inbox,indent,indent-decrease,indent-increase,indian-rupee,infinity,info,inspect,inspection-panel,italic,iteration-ccw,iteration-cw,iv-bag,japanese-yen,joystick,kanban,kanban-square,kanban-square-dashed,kayak,kazakh-tenge,key,key-round,key-square,keyboard,keyboard-music,keyboard-off,lambda,lamp,lamp-ceiling,lamp-desk,lamp-floor,lamp-wall-down,lamp-wall-up,land-plot,landmark,languages,laptop,laptop-2,laptop-minimal,laptop-minimal-check,lasso,lasso-select,laugh,layer-arrow-down,layer-arrow-up,layers,layers-2,layers-3,layers-arrow-down,layers-arrow-up,layers-minus,layers-plus,layout,layout-arrow-down,layout-arrow-right,layout-dashboard,layout-freeform,layout-grid,layout-grid-circles,layout-list,layout-panel-left,layout-panel-top,layout-template,leaf,leafy-green,lectern,lens,lens-concave,lens-convex,letter-spacing,letter-text,letters,library,library-big,library-square,life-buoy,ligature,lightbulb,lightbulb-off,lighthouse,line-chart,line-dot-bottom-vertical,line-dot-left-horizontal,line-dot-right-horizontal,line-dot-top-vertical,line-height,line-squiggle,line-style,link,link-2,link-2-off,list,list-check,list-checks,list-chevrons-down-up,list-chevrons-up-down,list-clock,list-collapse,list-end,list-filter,list-filter-plus,list-indent-decrease,list-indent-increase,list-minus,list-music,list-ordered,list-plus,list-restart,list-sort-ascending,list-sort-descending,list-start,list-todo,list-tree,list-video,list-x,loader,loader-2,loader-circle,loader-pinwheel,locate,locate-fixed,locate-off,location-edit,lock,lock-keyhole,lock-keyhole-open,lock-open,log-in,log-out,logs,lollipop,luggage,m-square,magnet,mail,mail-badge,mail-check,mail-clock,mail-dot,mail-minus,mail-open,mail-pen,mail-plus,mail-question,mail-question-mark,mail-search,mail-warning,mail-x,mailbox,mails,map,map-minus,map-pin,map-pin-check,map-pin-check-inside,map-pin-house,map-pin-minus,map-pin-minus-inside,map-pin-off,map-pin-pen,map-pin-plus,map-pin-plus-inside,map-pin-search,map-pin-x,map-pin-x-inside,map-pinned,map-plus,mars,mars-stroke,martini,maximize,maximize-2,medal,megaphone,megaphone-off,meh,memory-stick,menu,menu-square,merge,message-circle,message-circle-check,message-circle-code,message-circle-dashed,message-circle-dashed-check,message-circle-heart,message-circle-more,message-circle-off,message-circle-plus,message-circle-question,message-circle-question-mark,message-circle-reply,message-circle-text,message-circle-warning,message-circle-x,message-square,message-square-check,message-square-code,message-square-dashed,message-square-diff,message-square-dot,message-square-heart,message-square-lock,message-square-more,message-square-off,message-square-plus,message-square-quote,message-square-reply,message-square-share,message-square-text,message-square-warning,message-square-x,messages-circle,messages-square,metronome,mic,mic-2,mic-audio-lines,mic-off,mic-signal,mic-vocal,microchip,microscope,microwave,midi-port,milestone,milk,milk-off,minimize,minimize-2,minus,minus-circle,minus-square,mirror-rectangular,mirror-round,monitor,monitor-check,monitor-cloud,monitor-cog,monitor-dot,monitor-down,monitor-off,monitor-pause,monitor-pc,monitor-play,monitor-smartphone,monitor-speaker,monitor-stop,monitor-up,monitor-x,moon,moon-star,mop,mop-sparkles,more-horizontal,more-vertical,mosque,motorbike,mountain,mountain-snow,mouse,mouse-left,mouse-off,mouse-pointer,mouse-pointer-2,mouse-pointer-2-off,mouse-pointer-ban,mouse-pointer-click,mouse-pointer-square-dashed,mouse-right,mouth,mouth-off,move,move-3-d,move-3d,move-diagonal,move-diagonal-2,move-down,move-down-left,move-down-right,move-horizontal,move-left,move-right,move-up,move-up-left,move-up-right,move-vertical,music,music-2,music-3,music-4,navigation,navigation-2,navigation-2-off,navigation-off,nepali-rupee,network,newspaper,nfc,non-binary,notebook,notebook-dot,notebook-pen,notebook-tabs,notebook-text,notepad-text,notepad-text-dashed,nut,nut-off,octagon,octagon-alert,octagon-minus,octagon-pause,octagon-x,omega,option,orbit,origami,outdent,package,package-2,package-check,package-minus,package-open,package-plus,package-search,package-x,paint-bucket,paint-roller,paintbrush,paintbrush-2,paintbrush-vertical,palette,palmtree,panda,panel-bottom,panel-bottom-close,panel-bottom-dashed,panel-bottom-inactive,panel-bottom-open,panel-left,panel-left-close,panel-left-dashed,panel-left-inactive,panel-left-open,panel-left-right-dashed,panel-right,panel-right-close,panel-right-dashed,panel-right-inactive,panel-right-open,panel-top,panel-top-bottom-dashed,panel-top-close,panel-top-dashed,panel-top-inactive,panel-top-open,panels-left-bottom,panels-left-right,panels-right-bottom,panels-top-bottom,panels-top-left,paper-bag,paperclip,parasol,parentheses,park,parking-circle,parking-circle-off,parking-meter,parking-square,parking-square-off,party-popper,pause,pause-circle,pause-octagon,paw-print,pc-case,pen,pen-box,pen-line,pen-off,pen-square,pen-tool,pencil,pencil-line,pencil-off,pencil-ruler,pencil-sparkles,pentagon,percent,percent-circle,percent-diamond,percent-square,perfume-bottle,person-standing,phi,philippine-peso,phone,phone-call,phone-forwarded,phone-incoming,phone-log,phone-missed,phone-off,phone-outgoing,pi,pi-square,piano,pickaxe,picture-in-picture,picture-in-picture-2,pie-chart,piggy-bank,pilcrow,pilcrow-left,pilcrow-right,pilcrow-square,pill,pill-bottle,pin,pin-off,pipette,pizza,plane,plane-landing,plane-takeoff,plant-pot,play,play-circle,play-off,play-square,playing-card,playing-cards,playing-cards-fan,plug,plug-2,plug-zap,plug-zap-2,plus,plus-circle,plus-square,pocket-knife,podcast,podium,pointer,pointer-off,popcorn,popsicle,pound-sterling,power,power-circle,power-off,power-square,presentation,printer,printer-3d,printer-check,printer-x,projector,proportions,puzzle,pyramid,qr-code,quote,rabbit,radar,radiation,radical,radio,radio-off,radio-receiver,radio-tower,radius,rainbow,rat,ratio,receipt,receipt-cent,receipt-euro,receipt-indian-rupee,receipt-japanese-yen,receipt-pound-sterling,receipt-russian-ruble,receipt-swiss-franc,receipt-text,receipt-turkish-lira,rectangle-circle,rectangle-ellipsis,rectangle-goggles,rectangle-horizontal,rectangle-vertical,recycle,redo,redo-2,redo-dot,refresh-ccw,refresh-ccw-dot,refresh-cw,refresh-cw-off,refrigerator,regex,remove-formatting,repeat,repeat-1,repeat-2,repeat-off,replace,replace-all,reply,reply-all,rewind,ribbon,road,robot-arm,robot-vacuum,rocket,rocking-chair,roller-coaster,rose,rotate-3-d,rotate-3d,rotate-ccw,rotate-ccw-clock,rotate-ccw-key,rotate-ccw-square,rotate-cw,rotate-cw-clock,rotate-cw-fading-clock,rotate-cw-square,route,route-off,router,rows,rows-2,rows-3,rows-4,rss,rugby-ball,ruler,ruler-dimension-line,russian-ruble,sailboat,salad,sandwich,satellite,satellite-dish,saudi-riyal,save,save-all,save-check,save-off,save-pen,save-plus,scale,scale-3-d,scale-3d,scaling,scan,scan-barcode,scan-box,scan-eye,scan-face,scan-heart,scan-line,scan-qr-code,scan-search,scan-square,scan-text,scatter-chart,school,school-2,scissors,scissors-line-dashed,scissors-square,scissors-square-dashed-bottom,scooter,scratch-blocks,screen-share,screen-share-off,screw,scroll,scroll-text,search,search-alert,search-check,search-code,search-slash,search-x,section,send,send-horizonal,send-horizontal,send-to-back,separator-horizontal,separator-vertical,server,server-cog,server-crash,server-nas,server-off,server-plus,settings,settings-2,shapes,share,share-2,sheet,shell,shelving-unit,shield,shield-alert,shield-ban,shield-check,shield-close,shield-cog,shield-cog-corner,shield-ellipsis,shield-half,shield-house,shield-keyhole,shield-lock,shield-minus,shield-off,shield-plus,shield-question,shield-question-mark,shield-user,shield-x,ship,ship-cargo,ship-wheel,shirt,shopping-bag,shopping-basket,shopping-cart,shopping-cart-minus,shopping-cart-plus,shovel,shower-head,shredder,shrimp,shrimp-off,shrink,shrub,shuffle,sidebar,sidebar-close,sidebar-open,sigma,sigma-square,signal,signal-high,signal-low,signal-medium,signal-zero,signature,signpost,signpost-big,siren,sixteenth-notes,skip-back,skip-forward,skull,slash,slash-square,slice,sliders,sliders-horizontal,sliders-vertical,smartphone,smartphone-charging,smartphone-nfc,smartphone-user-round,smile,smile-plus,snail,snowflake,soap-dispenser-droplet,sofa,solar-panel,sort-asc,sort-desc,soup,space,spade,sparkle,sparkles,speaker,speech,spell-check,spell-check-2,spline,spline-pointer,split,split-square-horizontal,split-square-vertical,spool,sport-shoe,spotlight,spray-can,sprout,square,square-activity,square-arrow-down,square-arrow-down-left,square-arrow-down-right,square-arrow-left,square-arrow-out-down-left,square-arrow-out-down-right,square-arrow-out-up-left,square-arrow-out-up-right,square-arrow-right,square-arrow-right-enter,square-arrow-right-exit,square-arrow-up,square-arrow-up-left,square-arrow-up-right,square-asterisk,square-bookmark,square-bottom-dashed-scissors,square-centerline-dashed-horizontal,square-centerline-dashed-vertical,square-chart-gantt,square-check,square-check-big,square-chevron-down,square-chevron-left,square-chevron-right,square-chevron-up,square-code,square-dashed,square-dashed-bottom,square-dashed-bottom-code,square-dashed-kanban,square-dashed-mouse-pointer,square-dashed-plus,square-dashed-text,square-dashed-top-solid,square-dashed-x,square-dashed-x-corner,square-dimensions,square-divide,square-dot,square-equal,square-exclamation-point,square-function,square-gantt-chart,square-kanban,square-library,square-m,square-menu,square-minus,square-mouse-pointer,square-off,square-parking,square-parking-off,square-pause,square-pen,square-percent,square-pi,square-pilcrow,square-play,square-plus,square-power,square-radical,square-round-corner,square-scissors,square-sigma,square-slash,square-sparkles,square-split-horizontal,square-split-vertical,square-square,square-stack,square-star,square-stop,square-terminal,square-text,square-user,square-user-round,square-x,squares-exclude,squares-intersect,squares-subtract,squares-unite,squircle,squircle-dashed,squirrel,stamp,star,star-check,star-half,star-minus,star-off,star-plus,star-x,stars,step-back,step-forward,stethoscope,sticker,sticky-note,sticky-note-check,sticky-note-minus,sticky-note-off,sticky-note-plus,sticky-note-x,sticky-notes,stone,stop-circle,store,stretch-horizontal,stretch-vertical,strikethrough,subscript,subtitles,summary,sun,sun-dim,sun-medium,sun-moon,sun-snow,sunrise,sunset,superscript,swatch-book,swiss-franc,switch-camera,sword,swords,syringe,table,table-2,table-cells-merge,table-cells-split,table-columns-split,table-config,table-of-contents,table-properties,table-rows-split,tablet,tablet-smartphone,tablets,tag,tag-plus,tag-x,tags,tally-1,tally-2,tally-3,tally-4,tally-5,tangent,target,telescope,tent,tent-tree,terminal,terminal-square,test-tube,test-tube-2,test-tube-diagonal,test-tubes,text,text-align-center,text-align-end,text-align-justify,text-align-justify-center,text-align-justify-end,text-align-justify-start,text-align-start,text-cursor,text-cursor-input,text-initial,text-quote,text-search,text-select,text-selection,text-wrap,theater,thermometer,thermometer-snowflake,thermometer-sun,thumbs-down,thumbs-up,tic-tac-toe,ticket,ticket-check,ticket-minus,ticket-percent,ticket-plus,ticket-slash,ticket-x,tickets,tickets-plane,timeline,timer,timer-off,timer-reset,toggle-left,toggle-right,toilet,tombstone,tool-case,toolbox,toothbrush,toothbrush-sparkles,tornado,torus,touchpad,touchpad-off,towel-rack,tower-control,toy-brick,tractor,traffic-cone,trailer,train,train-front,train-front-tunnel,train-track,tram-front,transgender,trash,trash-2,trash-off,tree-deciduous,tree-palm,tree-pine,trees,trending-down,trending-up,trending-up-down,triangle,triangle-alert,triangle-dashed,triangle-right,triangles-centerline-dashed-horizontal,triangles-centerline-dashed-vertical,trophy,truck,truck-electric,tube-lotion,turkish-lira,turntable,turtle,tv,tv-2,tv-minimal,tv-minimal-play,type,type-outline,umbrella,umbrella-off,underline,undo,undo-2,undo-dot,unfold-horizontal,unfold-vertical,ungroup,university,unlink,unlink-2,unlock,unlock-keyhole,unplug,upload,upload-cloud,usb,usb-c-port,user,user-2,user-check,user-check-2,user-circle,user-circle-2,user-cog,user-cog-2,user-group,user-key,user-lock,user-minus,user-minus-2,user-pen,user-plus,user-plus-2,user-round,user-round-arrow-left,user-round-check,user-round-cog,user-round-group,user-round-key,user-round-minus,user-round-pen,user-round-plus,user-round-search,user-round-star,user-round-x,user-search,user-shield,user-square,user-square-2,user-star,user-x,user-x-2,users,users-2,users-collaboration,users-round,users-round-collaboration,utensils,utensils-crossed,utility-pole,van,variable,vault,vector-polygon,vector-square,vegan,venetian-mask,venus,venus-and-mars,verified,vibrate,vibrate-off,video,video-off,videotape,view,virus,virus-off,voicemail,volleyball,volume,volume-1,volume-2,volume-off,volume-x,vote,wallet,wallet-2,wallet-cards,wallet-minimal,wallpaper,wand,wand-2,wand-sparkles,warehouse,washing-machine,watch,waves,waves-arrow-down,waves-arrow-up,waves-horizontal,waves-ladder,waves-vertical,waypoints,webcam,webcam-off,webhook,webhook-off,weight,weight-tilde,wheat,wheat-off,whistle,whole-word,wifi,wifi-cog,wifi-high,wifi-lock,wifi-low,wifi-off,wifi-pen,wifi-sync,wifi-zero,wind,wind-arrow-down,wind-arrow-up,wine,wine-off,workflow,worm,wrap-text,wrench,wrench-off,x,x-circle,x-line-top,x-octagon,x-square,zap,zap-off,zodiac-aquarius,zodiac-aries,zodiac-cancer,zodiac-capricorn,zodiac-gemini,zodiac-leo,zodiac-libra,zodiac-ophiuchus,zodiac-pisces,zodiac-sagittarius,zodiac-scorpio,zodiac-taurus,zodiac-virgo,zoom-in,zoom-out",
}

local RiftUI = {
	Version = "8f2d8b4",
	Flags = {},
	AssetBase = "https://raw.githubusercontent.com/Naymmmm/riftui/main/public/",
	Folder = "RiftUI",
	State = "Idle",
	StateHistory = {},
	Errors = {},
	Hubs = {},
	DeveloperMode = false,
}

-- Secure asset policy is shared by hubs created from this library instance.
local initialStealth = false
pcall(function()
	local env = typeof(getgenv) == "function" and getgenv() or _G
	initialStealth = env.RIFTUI_SECURE == true
end)
local bootStealth = initialStealth
local secureHubs = setmetatable({}, { __mode = "k" })
local localAssetIds = {}
local secureFontFamily = nil
local secureFontState = "idle"
local watchedAssets = setmetatable({}, { __mode = "k" })
local function secureAssets()
	return bootStealth or next(secureHubs) ~= nil
end
local nativeWarn = warn
local function warn(...)
	if not secureAssets() then nativeWarn(...) end
end
local function localImage(value)
	return value == "" or (type(value) == "string" and (localAssetIds[value] or string.match(value, "^rbxasset://") or string.match(value, "^rbxtemp://")))
end
local function secureProperty(prop, value)
	if not secureAssets() then return value end
	if (prop == "Image" or prop == "HoverImage" or prop == "PressedImage") and not localImage(value) then return "" end
	if prop == "FontFace" and typeof(value) == "Font" then
		local family = value.Family
		if type(family) == "string" and not localAssetIds[family] and (string.match(family, "^rbxassetid://") or string.match(family, "^https?://") or (secureFontFamily and family == Font.fromEnum(Enum.Font.BuilderSans).Family)) then
			local fallback = Font.fromEnum(Enum.Font.BuilderSans)
			return Font.new(secureFontFamily or fallback.Family, value.Weight, value.Style)
		end
	end
	return value
end
local function watchAsset(inst)
	if watchedAssets[inst] then return end
	local props = {}
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then table.insert(props, "Image") end
	if inst:IsA("ImageButton") then table.insert(props, "HoverImage") table.insert(props, "PressedImage") end
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then table.insert(props, "FontFace") end
	if #props == 0 then return end
	watchedAssets[inst] = true
	for _, prop in props do
		local function apply()
			local old = inst[prop]
			local value = secureProperty(prop, old)
			if value ~= old then inst[prop] = value end
		end
		inst:GetPropertyChangedSignal(prop):Connect(apply)
		apply()
	end
end

---------------------------------------------------------------- services
local function service(name)
	local s = game:GetService(name)
	if cloneref then
		s = cloneref(s)
	end
	return s
end
local Players = service("Players")
local TweenService = service("TweenService")
local UserInputService = service("UserInputService")
local HttpService = service("HttpService")
local RunService = service("RunService")
local CoreGui = service("CoreGui")
local GuiService = service("GuiService")

local hasFS = typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
local hasAssets = hasFS and typeof(getcustomasset) == "function"
local clock = os.clock()

local function topInset(): number
	local ok, inset = pcall(function()
		return GuiService:GetGuiInset()
	end)
	return ok and inset and inset.Y or 58
end

local function viewport(): Vector2
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

---------------------------------------------------------------- state machine & error log
local listeners = {}

local function notifyListeners()
	for _, fn in listeners do
		task.spawn(fn)
	end
end

local function setState(state: string, detail: string?)
	if RiftUI.State == state and detail == nil then
		return
	end
	RiftUI.State = state
	table.insert(RiftUI.StateHistory, { State = state, Detail = detail, Time = os.clock() - clock })
	if #RiftUI.StateHistory > 30 then
		table.remove(RiftUI.StateHistory, 1)
	end
	notifyListeners()
end

local function recordError(message: string, trace: string?, source: string?)
	table.insert(RiftUI.Errors, { Message = message, Trace = trace, Source = source or "hub", Time = os.clock() - clock })
	if #RiftUI.Errors > 50 then
		table.remove(RiftUI.Errors, 1)
	end
	notifyListeners()
end

function RiftUI:OnStateChanged(fn)
	table.insert(listeners, fn)
	return {
		Disconnect = function()
			local i = table.find(listeners, fn)
			if i then
				table.remove(listeners, i)
			end
		end,
	}
end

---------------------------------------------------------------- theme
local rgb = Color3.fromRGB
local DefaultTheme = {
	Panel = rgb(15, 15, 17),
	PanelStroke = rgb(42, 42, 48),
	Highlight = rgb(255, 255, 255), -- 1px top sheen on floating surfaces
	Tile = rgb(23, 23, 26),
	TileHover = rgb(30, 30, 34),
	TileActive = rgb(38, 38, 43),
	TileStroke = rgb(34, 34, 39),
	TileActiveStroke = rgb(52, 52, 59),
	Section = rgb(20, 20, 23),
	SectionStroke = rgb(34, 34, 39),
	Divider = rgb(29, 29, 33),
	Text = rgb(237, 237, 239),
	SubText = rgb(142, 142, 150),
	Muted = rgb(95, 95, 103),
	Field = rgb(10, 10, 12),
	FieldStroke = rgb(42, 42, 48),
	Track = rgb(42, 42, 48),
	Knob = rgb(110, 110, 118),
	Accent = rgb(242, 242, 243),
	AccentText = rgb(15, 15, 17),
	Danger = rgb(255, 112, 112),
	Success = rgb(120, 220, 150),
	Warning = rgb(242, 194, 79),
	Scrim = rgb(0, 0, 0),
}

local FONT_ID = "rbxassetid://12187365364" -- Inter
local function inter(weight)
	local family = secureAssets() and (secureFontFamily or Font.fromEnum(Enum.Font.BuilderSans).Family) or FONT_ID
	return Font.new(family, weight or Enum.FontWeight.Regular)
end
local MONO = Font.fromName("RobotoMono", Enum.FontWeight.Medium)

local FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SOFT = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
-- Shared motion timings: 140ms feedback, 200-220ms controls, 320ms panels,
-- 160ms dismissal. Existing property-aware tween() handles interruptions.
local RISE = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local FOLD = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local THEME_FADE = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SETTLE = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

---------------------------------------------------------------- helpers
local themeBindings = setmetatable({}, { __mode = "k" })
local function themeColor(theme, key)
	return { _theme = theme, _key = key }
end
local function setThemed(inst, prop, value)
	value = secureProperty(prop, value)
	if type(value) == "table" and rawget(value, "_theme") then
		local bindings = themeBindings[inst] or {}
		themeBindings[inst] = bindings
		bindings[prop] = value
		inst[prop] = value._theme[value._key]
	else
		inst[prop] = value
	end
end

local function create(className: string, props: { [string]: any }?, children: { Instance }?)
	local inst = Instance.new(className)
	local parent
	for k, v in props or {} do
		if k == "Parent" then
			parent = v
		else
			setThemed(inst, k, v)
		end
	end
	for _, c in children or {} do
		c.Parent = inst
	end
	watchAsset(inst)
	if parent then
		inst.Parent = parent
	end
	return inst
end

-- a hairline of light along the top edge, inset from the corners, so dark surfaces read as objects
local function sheen(parent: Instance, inset: number, theme, zIndex: number?)
	return create("Frame", {
		Name = "Sheen",
		BackgroundColor3 = themeColor(theme, "Highlight"),
		BackgroundTransparency = 0.93,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(inset, 0),
		Size = UDim2.new(1, -inset * 2, 0, 1),
		ZIndex = zIndex or 1,
		Parent = parent,
	})
end

local function corner(r: number)
	return create("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function stroke(color, thickness: number?, transparency: number?)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(t: number, r: number?, b: number?, l: number?)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r or t),
		PaddingBottom = UDim.new(0, b or t),
		PaddingLeft = UDim.new(0, l or r or t),
	})
end

local function list(dir, pad: number, halign, valign)
	return create("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, pad or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
	})
end

local function text(props)
	local t = create("TextLabel", {
		BackgroundTransparency = 1,
		FontFace = props.FontFace or inter(),
		TextSize = props.TextSize or 13,
		TextColor3 = props.TextColor3 or DefaultTheme.Text,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		Text = props.Text or "",
		Size = props.Size or UDim2.new(1, 0, 0, 16),
		AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.None,
		TextWrapped = props.TextWrapped or false,
		LineHeight = props.LineHeight or (props.TextWrapped and 1.2 or 1),
		TextTruncate = props.TextTruncate or Enum.TextTruncate.None,
		RichText = props.RichText or false,
		LayoutOrder = props.LayoutOrder or 0,
		Position = props.Position or UDim2.new(),
		AnchorPoint = props.AnchorPoint or Vector2.zero,
		TextTransparency = props.TextTransparency or 0,
		ZIndex = props.ZIndex or 1,
		Name = props.Name or "Label",
	})
	if props.Parent then
		t.Parent = props.Parent
	end
	return t
end

-- Motion runtime, inlined by scripts/bundle.mjs.
-- One owner per instance/property avoids overlapping tweens and unbounded listeners.
local motionByInstance = setmetatable({}, { __mode = "k" })
local motionTargets = setmetatable({}, { __mode = "k" })

local function cancelMotion(inst: Instance)
	local properties = motionByInstance[inst]
	if not properties then return end
	local seen = {}
	for _, active in properties do
		if not seen[active] then
			seen[active] = true
			active:Cancel()
		end
	end
	motionByInstance[inst] = nil
	motionTargets[inst] = nil
end

local function cancelHubMotion(gui: Instance?)
	if not gui then return end
	cancelMotion(gui)
	for _, inst in gui:GetDescendants() do
		cancelMotion(inst)
	end
end

local function tween(inst: Instance, info: TweenInfo, goals)
    -- Shared motion mode resolves from the owning ScreenGui. It applies to all
    -- animations, including ModuleCard, popup, weather UI and control skins,
    -- while keeping the existing Motion owner/property arbitration intact.
    local ancestor = inst
    local motionMode = "Full"
    while ancestor do
        if ancestor:IsA("ScreenGui") then
            motionMode = ancestor:GetAttribute("RelaxMotionMode") or "Full"
            break
        end
        ancestor = ancestor.Parent
    end
    if motionMode == "Off" then
        info = TweenInfo.new(.001, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    elseif motionMode == "Reduced" then
        info = TweenInfo.new(math.min(info.Time, .08), Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out)
    end
	local resolved = {}
	for prop, value in goals do
		if type(value) == "table" and rawget(value, "_theme") then
			local bindings = themeBindings[inst] or {}
			themeBindings[inst] = bindings
			bindings[prop] = value
			resolved[prop] = value._theme[value._key]
		else
			resolved[prop] = value
		end
	end
	local active = motionByInstance[inst]
	if not active then
		active = {}
		motionByInstance[inst] = active
	end
	local targets = motionTargets[inst] or {}
	local sameTween, identical = nil, true
	for prop, target in resolved do
		local current = targets[prop]
		if not current or current.Value ~= target or current.Info ~= info or
			(sameTween and sameTween ~= current.Tween) then
			identical = false
			break
		end
		sameTween = current.Tween
	end
	if identical and sameTween then return sameTween end
	local conflicting = {}
	for prop in resolved do
		local previous = active[prop]
		if previous then conflicting[previous] = true end
	end
	for previous in conflicting do previous:Cancel() end

	local tw = TweenService:Create(inst, info, resolved)
	motionTargets[inst] = targets
	for prop, target in resolved do
		active[prop] = tw
		targets[prop] = { Tween = tw, Value = target, Info = info }
	end
	local completed
	completed = tw.Completed:Connect(function()
		if completed then completed:Disconnect() completed = nil end
		for prop in resolved do
			if active[prop] == tw then active[prop] = nil end
			local target = targets[prop]
			if target and target.Tween == tw then targets[prop] = nil end
		end
		if not next(active) then
			motionByInstance[inst] = nil
			motionTargets[inst] = nil
		end
	end)
	tw:Play()
	return tw
end

-- Unified owner/id state transitions.  All component animations still use
-- the property-aware tween() above, so this does not create a second tween
-- registry.  A superseding state cancels the previous group as a unit.
local Motion = {}
Motion.Presets = {
    Micro = TweenInfo.new(.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Control = TweenInfo.new(.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Panel = TweenInfo.new(.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Ripple = TweenInfo.new(.52, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Dismiss = TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
}

local motionByOwner = setmetatable({}, { __mode = "k" })

local function dropMotionEntry(entry)
    if entry.Cancelled then return end
    entry.Cancelled = true
    for _, conn in entry.Connections do conn:Disconnect() end
    table.clear(entry.Connections)
    for _, active in entry.Tweens do active:Cancel() end
    table.clear(entry.Tweens)
end

function Motion.cancel(owner, id)
    local slots = motionByOwner[owner]
    if not slots then return end
    local entry = slots[id]
    if not entry then return end
    slots[id] = nil
    dropMotionEntry(entry)
    if not next(slots) then motionByOwner[owner] = nil end
end

function Motion.cancelAll(owner)
    local slots = motionByOwner[owner]
    if not slots then return end
    motionByOwner[owner] = nil
    for _, entry in slots do dropMotionEntry(entry) end
    table.clear(slots)
end

function Motion.getState(owner, id)
    local slots = motionByOwner[owner]
    local entry = slots and slots[id]
    return entry and entry.State or nil
end

function Motion.transition(owner, id, state, steps, preset, onComplete)
    assert(type(owner) == "table", "Motion owner must be a table")
    assert(id ~= nil, "Motion transition requires an id")
    if owner._destroyed then return nil end
    Motion.cancel(owner, id)
    local slots = motionByOwner[owner]
    if not slots then
        slots = {}
        motionByOwner[owner] = slots
    end
    local entry = { State = state, Tweens = {}, Connections = {}, Cancelled = false, Done = false }
    slots[id] = entry
    local count = 0
    local function finish()
        if entry.Cancelled or entry.Done or slots[id] ~= entry then return end
        entry.Done = true
        for _, conn in entry.Connections do conn:Disconnect() end
        table.clear(entry.Connections)
        table.clear(entry.Tweens)
        if onComplete and not owner._destroyed then onComplete(state) end
    end
    for _, step in steps or {} do
        local target = step.Target or step[1]
        local goals = step.Goals or step[2]
        if target and goals and target.Parent then
            count += 1
            local active = tween(target, step.Info or step.Preset or preset or Motion.Presets.Control, goals)
            table.insert(entry.Tweens, active)
            local conn = active.Completed:Connect(function(playback)
                if entry.Cancelled or slots[id] ~= entry then return end
                if playback ~= Enum.PlaybackState.Completed then
                    -- A competing property animation superseded this group.
                    Motion.cancel(owner, id)
                    return
                end
                count -= 1
                if count == 0 then finish() end
            end)
            table.insert(entry.Connections, conn)
        end
    end
    if count == 0 then finish() end
    return entry
end

function Motion.play(owner, id, target, goals, preset, onComplete)
    return Motion.transition(owner, id, id, {
        { Target = target, Goals = goals },
    }, preset, onComplete)
end

RiftUI.Motion = Motion


local function within(inst: GuiObject?, pos: Vector2): boolean
	if not inst or not inst.Parent or not inst.Visible then
		return false
	end
	local p, s = inst.AbsolutePosition, inst.AbsoluteSize
	return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
end

local function isPointer(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function round(n: number, step: number, origin: number?): number
	local base = origin or 0
	local r = base + math.floor((n - base) / step + 0.5) * step
	return tonumber(string.format("%.6f", r)) :: number
end

local function formatNumber(n: number, step: number): string
	if step >= 1 then
		return string.format("%d", math.floor(n + 0.5))
	end
	local decimals = math.clamp(math.ceil(-math.log10(step)), 1, 4)
	return string.format("%." .. decimals .. "f", n)
end

local function randomName(): string
	return string.format("%08x", math.random(0, 0x7fffffff))
end

local KEY_NAMES = {
	RightShift = "RShift",
	LeftShift = "LShift",
	RightControl = "RCtrl",
	LeftControl = "LCtrl",
	RightAlt = "RAlt",
	LeftAlt = "LAlt",
	Return = "Enter",
	Backspace = "Bksp",
	Escape = "Esc",
	PageUp = "PgUp",
	PageDown = "PgDn",
	Insert = "Ins",
	Delete = "Del",
	CapsLock = "Caps",
	Backquote = "`",
	Zero = "0",
	One = "1",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
	MouseButton1 = "MB1",
	MouseButton2 = "MB2",
	MouseButton3 = "MB3",
}
local function keyName(key): string
	if key == nil then
		return "None"
	end
	return KEY_NAMES[key.Name] or key.Name
end

---------------------------------------------------------------- assets (icons, shadow)
---------------------------------------------------------------- theme presets
-- Each preset overrides DefaultTheme; a hub's own Theme table overrides the preset.
local THEMES = {
	{ Name = "Graphite", Description = "Neutral near-black", Colors = {} },
	{
		Name = "Ink",
		Description = "True black, highest contrast",
		Colors = {
			Panel = rgb(6, 6, 7),
			PanelStroke = rgb(36, 36, 40),
			Tile = rgb(16, 16, 18),
			TileHover = rgb(23, 23, 26),
			TileActive = rgb(31, 31, 35),
			TileStroke = rgb(27, 27, 31),
			TileActiveStroke = rgb(46, 46, 52),
			Divider = rgb(23, 23, 26),
			Field = rgb(0, 0, 0),
			FieldStroke = rgb(36, 36, 40),
			Track = rgb(36, 36, 40),
			AccentText = rgb(6, 6, 7),
		},
	},
	{
		Name = "Slate",
		Description = "Cool blue-grey, blue accent",
		Colors = {
			Panel = rgb(13, 17, 23),
			PanelStroke = rgb(40, 48, 60),
			Tile = rgb(22, 27, 34),
			TileHover = rgb(28, 34, 43),
			TileActive = rgb(36, 44, 56),
			TileStroke = rgb(33, 40, 50),
			TileActiveStroke = rgb(52, 62, 78),
			Divider = rgb(30, 36, 46),
			Text = rgb(230, 237, 243),
			SubText = rgb(139, 148, 158),
			Muted = rgb(98, 108, 120),
			Field = rgb(8, 11, 15),
			FieldStroke = rgb(40, 48, 60),
			Track = rgb(40, 48, 60),
			Knob = rgb(110, 120, 135),
			Accent = rgb(127, 178, 255),
			AccentText = rgb(8, 14, 24),
		},
	},
	{
		Name = "Ember",
		Description = "Warm charcoal, orange accent",
		Colors = {
			Panel = rgb(17, 15, 14),
			PanelStroke = rgb(50, 43, 39),
			Tile = rgb(27, 24, 22),
			TileHover = rgb(35, 31, 28),
			TileActive = rgb(44, 39, 35),
			TileStroke = rgb(40, 35, 32),
			TileActiveStroke = rgb(62, 54, 48),
			Divider = rgb(34, 30, 27),
			Text = rgb(240, 235, 230),
			SubText = rgb(160, 150, 140),
			Muted = rgb(110, 101, 94),
			Field = rgb(11, 10, 9),
			FieldStroke = rgb(50, 43, 39),
			Track = rgb(50, 43, 39),
			Knob = rgb(125, 115, 106),
			Accent = rgb(255, 154, 90),
			AccentText = rgb(28, 16, 8),
		},
	},
}
RiftUI.Themes = THEMES

local function buildTheme(name: string?, overrides)
	local theme = table.clone(DefaultTheme)
	for _, preset in THEMES do
		if preset.Name == name then
			for k, v in preset.Colors do
				theme[k] = v
			end
		end
	end
	for k, v in overrides or {} do
		theme[k] = v
	end
	return theme
end

---------------------------------------------------------------- per-hub files: RiftUI/<Id>/...
local function hubId(options): string
	local raw = options.Id or options.Name or "RiftHub"
	local id = string.lower((string.gsub(string.gsub(raw, "%s+", "-"), "[^%w%-_]", "")))
	return id ~= "" and id or "hub"
end

local function readSetup(id: string)
	if not hasFS then
		return nil
	end
	local ok, data = pcall(function()
		local path = RiftUI.Folder .. "/" .. id .. "/setup.json"
		if not isfile(path) then
			return nil
		end
		return HttpService:JSONDecode(readfile(path))
	end)
	return ok and type(data) == "table" and data or nil
end

local Assets = { sheets = {}, failed = false, names = nil, shadow = nil }

local function ensureFolder(path: string)
	if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder(path) then
		makefolder(path)
	end
end

-- Download a file into the executor workspace once, then hand back its content id.
local function customAsset(fileName: string, remote: string): string?
	if not hasAssets or Assets.failed then
		return nil
	end
	local folder = RiftUI.AssetCacheFolder or (RiftUI.Folder .. "/assets")
	local path = folder .. "/" .. fileName
	local ok, result = pcall(function()
		if not isfile(path) then
			ensureFolder(RiftUI.Folder)
			ensureFolder(RiftUI.Folder .. "/assets")
			ensureFolder(folder)
			local body = game:HttpGet(RiftUI.AssetBase .. remote)
			if #body < 64 then
				error("asset download returned " .. #body .. " bytes")
			end
			writefile(path, body)
		end
		return getcustomasset(path)
	end)
	if not ok then
		Assets.failed = true
		recordError("couldn't load " .. remote .. ": " .. tostring(result), nil, "assets")
		warn("[RiftUI] couldn't load " .. remote .. ": " .. tostring(result) .. " (falling back to text icons)")
		return nil
	end
	if type(result) == "string" then localAssetIds[result] = true end
	return result
end

-- Family JSON is rebuilt from this session's content IDs; cached IDs may expire.
function RiftUI:GetSecureFontStatus()
	return secureFontState, secureFontFamily
end

function RiftUI:LoadSecureFont()
	if secureFontState == "loading" or secureFontState == "ready" then return secureFontState == "ready" end
	secureFontState = "loading"
	local ok, result = pcall(function()
		assert(hasAssets, "local assets unavailable")
		local folder = (self.AssetCacheFolder or (self.Folder .. "/assets")) .. "/fonts/inter-4.1"
		local prefix = ""
		for part in string.gmatch(folder, "[^/]+") do
			prefix = prefix == "" and part or prefix .. "/" .. part
			ensureFolder(prefix)
		end
		local faces = {}
		for _, face in { { "Regular", 400 }, { "Medium", 500 }, { "SemiBold", 600 }, { "Bold", 700 } } do
			local file = "Inter-" .. face[1] .. ".ttf"
			local path = folder .. "/" .. file
			local function valid(bytes)
				return type(bytes) == "string" and #bytes > 1024 and #bytes < 2097152 and (string.sub(bytes, 1, 4) == "\0\1\0\0" or string.sub(bytes, 1, 4) == "OTTO")
			end
			local bytes = isfile(path) and readfile(path) or nil
			if not valid(bytes) then
				bytes = game:HttpGet(self.AssetBase .. "assets/fonts/inter-4.1/" .. file)
				assert(valid(bytes), "invalid font download")
				writefile(path, bytes)
			end
			local asset = getcustomasset(path)
			assert(type(asset) == "string" and asset ~= "", "font asset registration failed")
			table.insert(faces, { name = face[1], weight = face[2], style = "normal", assetId = asset })
		end
		local json = HttpService:JSONEncode({ name = "Inter", faces = faces })
		local hash = 5381
		for i = 1, #json do hash = (hash * 33 + string.byte(json, i)) % 4294967296 end
		local path = folder .. "/Inter-" .. string.format("%08x", hash) .. ".font"
		writefile(path, json)
		local family = getcustomasset(path)
		assert(type(family) == "string" and family ~= "", "font family registration failed")
		local info = service("TextService"):GetFamilyInfoAsync(family)
		assert(type(info) == "table" and type(info.Faces) == "table" and #info.Faces >= 4, "font family could not be loaded")
		Font.new(family, Enum.FontWeight.Regular)
		return family
	end)
	if not ok then
		secureFontState = "failed"
		recordError("local Inter font unavailable: " .. tostring(result), nil, "fonts")
		return false
	end
	secureFontFamily = result
	localAssetIds[result] = true
	secureFontState = "ready"
	if secureAssets() then
		local fallback = Font.fromEnum(Enum.Font.BuilderSans).Family
		for _, hub in self.Hubs do
			if not hub._destroyed then
				for _, inst in hub.Gui:GetDescendants() do
					if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
						local font = inst.FontFace
						if font.Family == fallback or font.Family == FONT_ID then inst.FontFace = Font.new(result, font.Weight, font.Style) end
					end
				end
			end
		end
	end
	return true
end

local function queueSecureFont()
	if secureAssets() and secureFontState == "idle" then task.defer(function() RiftUI:LoadSecureFont() end) end
end

local function iconIndex(name: string): number?
	if not Assets.names then
		Assets.names = {}
		local i = 0
		for n in string.gmatch(ICON_INDEX.Names, "[^,]+") do
			Assets.names[n] = i
			i += 1
		end
	end
	return Assets.names[name]
end

-- Returns { Image, ImageRectOffset, ImageRectSize } for a Lucide icon name, or nil.
function RiftUI:GetIcon(name: string?)
	if type(name) ~= "string" then
		return nil
	end
	if string.find(name, "^rbxasset") or string.find(name, "^rbxtemp://") then
		if secureAssets() and not localImage(name) then return nil end
		return { Image = name, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
	end
	local idx = iconIndex(name)
	if not idx then
		warn("[RiftUI] unknown Lucide icon '" .. name .. "'")
		return nil
	end
	local sheet = idx // ICON_INDEX.PerSheet
	local image = Assets.sheets[sheet]
	if not image then
		image = customAsset(string.format("lucide-%s-%d.png", ICON_INDEX.Version, sheet), "assets/lucide/sheet-" .. sheet .. ".png")
		if not image then
			return nil
		end
		Assets.sheets[sheet] = image
	end
	local cell = idx % ICON_INDEX.PerSheet
	local c, inset = ICON_INDEX.Cell, ICON_INDEX.Inset
	return {
		Image = image,
		ImageRectOffset = Vector2.new((cell % ICON_INDEX.PerRow) * c + inset, (cell // ICON_INDEX.PerRow) * c + inset),
		ImageRectSize = Vector2.new(c - inset * 2, c - inset * 2),
	}
end

local function iconLabel(name: string?, size: number, color: Color3, props)
	local data = RiftUI:GetIcon(name)
	if not data then
		return nil
	end
	local img = create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Image = data.Image,
		ImageRectOffset = data.ImageRectOffset,
		ImageRectSize = data.ImageRectSize,
		ImageColor3 = color,
	})
	for k, v in props or {} do
		img[k] = v
	end
	return img
end

-- A hub's own mark: a Lucide icon name, or an image (rbxassetid://…, an asset number, or a
-- getcustomasset id). Images keep their colours and draw a little larger than line icons.
-- Nil when there's nothing to draw, so callers fall back to the name's initial.
local function hubMark(icon, size: number, theme, props)
	if type(icon) == "string" and icon ~= "" then
		local lucide = iconLabel(icon, size, theme.Text, props)
		if lucide then return lucide end
	end
	local image
	if type(icon) == "number" or (type(icon) == "string" and string.match(icon, "^%d+$")) then
		image = "rbxassetid://" .. tostring(math.floor(tonumber(icon) or 0))
	elseif type(icon) == "string" and (string.match(icon, "^rbxassetid://%d+$") or string.match(icon, "^rbxasset://") or localAssetIds[icon]) then
		image = icon
	end
	-- stealth mode refuses remote images, so the initial stands in
	if not image or (secureAssets() and not localImage(image)) then return nil end
	local s = math.floor(size * 1.375 + 0.5)
	local img = create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, Image = image, ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromOffset(s, s) }, { corner(math.floor(s / 4)) })
	for k, v in props or {} do
		img[k] = v
	end
	return img
end

-- 9-slice soft shadow sized to its parent plus `spread` on every side
local function shadow(parent: Instance, spread: number?, zIndex: number?, offsetY: number?)
	if Assets.shadow == nil then
		Assets.shadow = customAsset("shadow-3.png", "assets/shadow.png") or false
	end
	if not Assets.shadow then
		return nil
	end
	spread = spread or 20
	return create("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = Assets.shadow,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(39, 39, 41, 41),
		SliceScale = spread / 20,
		ImageTransparency = 0.1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, offsetY or 4),
		Size = UDim2.new(1, spread * 2, 1, spread * 2),
		ZIndex = zIndex or 0,
		Parent = parent,
	})
end

local function guiParent()
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then
			return hui
		end
	end
	local ok = pcall(function()
		return CoreGui:GetChildren()
	end)
	if ok then
		return CoreGui
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

---------------------------------------------------------------- dialogs (prompts, the failure card)
-- A centred card over a scrim. Buttons: { Text, Primary?, Danger?, Callback?, KeepOpen? }
local function dialog(gui: Instance, theme, o)
	local layer = create("Frame", {
		Name = "Dialog",
		BackgroundColor3 = themeColor(theme, "Scrim"),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Active = true,
		ZIndex = 100,
		Parent = gui,
	})
	local holder = create("Frame", {
		Name = "Holder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 12),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 61,
		Parent = layer,
	})
	create("UISizeConstraint", { MaxSize = Vector2.new(o.Width or 360, 100000), Parent = holder })
	shadow(holder, 30, 61, 8)
	local card = create("CanvasGroup", {
		Name = "Card",
		BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		GroupTransparency = 1,
		ZIndex = 62,
		Parent = holder,
	}, { corner(14), padding(18, 18, 16, 18), list(Enum.FillDirection.Vertical, 10) })
	local outline = create("Frame", { Name = "Outline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 63, Parent = holder }, {
		corner(14),
		stroke(themeColor(theme, "PanelStroke")),
	})
	local head = create("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), ZIndex = 62, Parent = card }, {
		list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
	})
	local icon = iconLabel(o.Icon, 18, o.Tone or theme.Text, { ZIndex = 63 })
	if icon then
		icon.Parent = head
	end
	text({ Parent = head, Text = o.Title or "", FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 16, Size = UDim2.new(1, -30, 0, 22), LayoutOrder = 2, ZIndex = 63 })
	if o.Content and o.Content ~= "" then
		text({
			Parent = card,
			Text = o.Content,
			TextSize = 13,
			TextColor3 = themeColor(theme, "SubText"),
			TextWrapped = true,
			LineHeight = 1.3,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
			ZIndex = 63,
		})
	end
	local body = create("Frame", { Name = "Body", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, ZIndex = 62, Parent = card }, {
		list(Enum.FillDirection.Vertical, 8),
	})
	local closed = false
	local handle = {}
	local function close()
		if closed then return end
		closed = true
		-- Button-driven dismissal and API-driven dismissal must both pop the
		-- entry immediately rather than waiting for the closing fade.
		if handle.OnClosed then handle.OnClosed() end
		tween(layer, FOLD, { BackgroundTransparency = 1 })
		outline.Visible = false
		local tw = tween(card, FOLD, { GroupTransparency = 1 })
		tw.Completed:Connect(function()
			layer:Destroy()
		end)
	end
	local row = create("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 4, ZIndex = 62, Parent = card }, {
		list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
	})
	for i, b in o.Buttons or { { Text = "OK", Primary = true } } do
		local btn = create("TextButton", {
			Name = "Button",
			BackgroundColor3 = b.Primary and themeColor(theme, "Accent") or themeColor(theme, "Tile"),
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = b.Text,
			FontFace = inter(Enum.FontWeight.Medium),
			TextSize = 13,
			TextColor3 = b.Primary and themeColor(theme, "AccentText") or (b.Danger and themeColor(theme, "Danger") or themeColor(theme, "Text")),
			AutoButtonColor = false,
			LayoutOrder = i,
			ZIndex = 63,
			Parent = row,
		}, { corner(8), padding(0, 14) })
		if not b.Primary then
			stroke(themeColor(theme, "FieldStroke")).Parent = btn
		end
		btn.MouseEnter:Connect(function()
			tween(btn, FAST, { BackgroundColor3 = b.Primary and rgb(255, 255, 255) or theme.TileHover })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, FAST, { BackgroundColor3 = b.Primary and themeColor(theme, "Accent") or themeColor(theme, "Tile") })
		end)
		btn.MouseButton1Click:Connect(function()
			if not b.KeepOpen then
				close()
			end
			if b.Callback then
				task.spawn(b.Callback, btn)
			end
		end)
	end
	tween(layer, SOFT, { BackgroundTransparency = 0.55 })
	-- Keep the modal anchored to its available viewport.
	tween(card, SOFT, { GroupTransparency = 0 })
	handle.Layer, handle.Body, handle.Close = layer, body, close
	return handle
end

---------------------------------------------------------------- the error handler
local failureGui

local function showFailure(message: string, trace: string?)
	local hub = RiftUI.Hubs[#RiftUI.Hubs]
	local gui = hub and hub.Gui
	if not gui or not gui.Parent then
		if failureGui and failureGui.Parent then
			failureGui:Destroy()
		end
		failureGui = create("ScreenGui", {
			Name = "RiftUI_Failure",
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			DisplayOrder = 200,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Parent = guiParent(),
		})
		gui = failureGui
	end
	local theme = hub and hub.Theme or DefaultTheme
	local short = string.gsub(message, "^%[string \"(.-)\"%]", "%1")
	local buttons = {
		{
			Text = "Copy error",
			KeepOpen = true,
			Callback = function(btn)
				if typeof(setclipboard) == "function" then
					setclipboard(message .. "\n" .. (trace or ""))
					btn.Text = "Copied"
				else
					btn.Text = "No clipboard"
				end
			end,
		},
	}
	if hub and #hub._recipe > 0 then
		table.insert(buttons, {
			Text = "Reinitialize",
			Callback = function()
				hub:Reinitialize()
			end,
		})
	end
	table.insert(buttons, {
		Text = "Dismiss",
		Primary = true,
		Callback = function()
			task.delay(0.3, function()
				if failureGui then
					failureGui:Destroy()
					failureGui = nil
				end
			end)
		end,
	})
	local d = dialog(gui, theme, {
		Icon = "triangle-alert",
		Tone = theme.Danger,
		Title = "Hub failed to load",
		Content = hub and "Part of the hub was built before the error; what loaded still works." or "The script stopped before the hub was created.",
		Width = 420,
		Buttons = buttons,
	})
	local box = create("Frame", {
		Name = "Error",
		BackgroundColor3 = themeColor(theme, "Field"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ZIndex = 63,
		Parent = d.Body,
	}, { corner(8), stroke(themeColor(theme, "FieldStroke")), padding(10, 12), create("UISizeConstraint", { MaxSize = Vector2.new(math.huge, 160) }) })
	text({
		Parent = box,
		Text = (RiftUI.DeveloperMode and trace) and (short .. "\n" .. trace) or short,
		FontFace = MONO,
		TextSize = 12,
		TextColor3 = themeColor(theme, "Text"),
		TextWrapped = true,
		LineHeight = 1.25,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 64,
	})
	text({
		Parent = d.Body,
		Text = RiftUI.DeveloperMode and "Developer Mode keeps every error under Developer › Errors." or ("RiftUI " .. RiftUI.Version),
		TextSize = 11,
		TextColor3 = themeColor(theme, "Muted"),
		LayoutOrder = 2,
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 63,
	})
end

-- Pass to xpcall: xpcall(function() ... end, Rift.HandleError)
function RiftUI.HandleError(err: any): string
	local message = tostring(err)
	local trace = debug.traceback("", 2)
	recordError(message, trace, "load")
	setState("Failed", message)
	warn("[RiftUI] hub failed to load: " .. message)
	-- the handler runs on the failing stack; build the card once it has unwound
	task.defer(showFailure, message, trace)
	return message
end

---------------------------------------------------------------- Hub
local Hub = {}
Hub.__index = Hub

local function devFile()
	return RiftUI.Folder .. "/developer.txt"
end
if hasFS then
	local ok, on = pcall(function()
		return isfile(devFile()) and readfile(devFile()) == "1"
	end)
	RiftUI.DeveloperMode = ok and on or false
end

function RiftUI:CreateHub(options)
	options = options or {}
	setState("Booting", options.Name)
	local id = hubId(options)
	-- running the script again replaces the previous copy of this hub instead of stacking a second one
	local registry = {}
	pcall(function()
		local genv = typeof(getgenv) == "function" and getgenv() or _G
		genv.__RiftUIHubs = genv.__RiftUIHubs or {}
		registry = genv.__RiftUIHubs
	end)
	local previous = registry[id]
	if previous and previous.Destroy and not previous._destroyed then
		pcall(previous.Destroy, previous)
	end
	local saved = readSetup(id)
	local themeName = (saved and (saved.ColorTheme or saved.Theme)) or options.ColorTheme or options.ThemeName or "Graphite"
	local overrides = table.clone(options.Theme or {})
	if saved and type(saved.Studio) == "table" then
		for k, hex in saved.Studio.Colors or {} do
			local ok, col = pcall(Color3.fromHex, hex)
			if ok then
				overrides[k] = col
			end
		end
	end
	local theme = buildTheme(themeName, overrides)
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
	if saved and saved.ToggleKey then
		local ok, key = pcall(function()
			return Enum.KeyCode[saved.ToggleKey]
		end)
		if ok and key then
			toggleKey = key
		end
	end
	local self = setmetatable({
		Options = options,
		Id = id,
		Name = options.Name or "Rift Hub",
		Subtitle = options.Subtitle or "",
		Icon = options.HubIcon,
		Theme = theme,
		ThemeName = themeName,
		_controlTheme = (saved and saved.ControlTheme == "Rounded") and "Rounded" or
			(options.ControlTheme == "Rounded" and "Rounded" or "Default"),
		ToggleKey = toggleKey,
		CommandKey = (saved and saved.CommandKey and Enum.KeyCode[saved.CommandKey]) or options.CommandKey or Enum.KeyCode.F2,
		SetupData = saved,
		Flags = RiftUI.Flags,
		Tabs = {},
		Pins = {},
		Stealth = false,
		_conns = {},
		_recipe = {},
		_popup = nil,
		_open = nil,
		_visible = true,
		_scale = 1,
        -- Saved geometry belongs to each page. Legacy global PanelSize is
        -- deliberately not applied to all tabs when upgrading.
        _panelSizes = type(saved and saved.PanelSizes) == "table"
            and table.clone(saved.PanelSizes) or {},
	}, Hub)

	self:_initDesignTokens(options, saved)
	assert(options.Stealth == nil or type(options.Stealth) == "boolean", "Stealth must be a boolean")
	assert(options.HubIcon == nil or type(options.HubIcon) == "string" or type(options.HubIcon) == "number", "HubIcon must be a Lucide icon name or an image asset ID")
	local stealth = options.Stealth
	if stealth == nil then stealth = initialStealth end
	self._stealthLocked = options.Stealth ~= nil or initialStealth
	self.Stealth = stealth == true
	if self.Stealth then secureHubs[self] = true end
	bootStealth = false
	self:SetUISounds((saved and saved.UISounds) or options.UISounds or options.Sounds or {})
	self:_initRequirements(options.Requirements)
	local gui = create("ScreenGui", {
		Name = "RiftUI",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
	})
	if typeof(protectgui) == "function" then
		pcall(protectgui, gui)
	end
	gui.Parent = guiParent()
	self.Gui = gui
	self:_connect(gui.DescendantAdded, watchAsset)
	self.UIScale = create("UIScale", { Scale = 1, Parent = gui })
	self:_connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
		self:_requestPanelFit()
	end)

	-- Dock: a slim strip of 40px tiles
	self.DockHolder = create("Frame", {
		Name = "DockHolder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -self:_dockBottom()),
		Size = UDim2.fromOffset(0, 50),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = gui,
	})
	shadow(self.DockHolder, 18, 0, 5)
	self.Dock = create("Frame", {
		Name = "Dock",
		BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.fromOffset(0, 50),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 2,
		Parent = self.DockHolder,
	}, {
		corner(12),
		stroke(themeColor(theme, "PanelStroke")),
		padding(5),
		list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
	})
	sheen(self.DockHolder, 12, theme, 3)
	-- Separate real Dock groups: navigation on the left, utilities on the right.
	self.DefaultTabGroup = self:TabGroup({ Name = "Main", Order = 0, _internal = true })
	self.SettingsGroup = self:TabGroup({ Name = "Settings", Order = 10000, Separator = true, _internal = true })

	-- Tooltip pill under the dock
	self.Tooltip = create("Frame", {
		Name = "Tooltip",
		BackgroundColor3 = themeColor(theme, "Panel"),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		ZIndex = 20,
		Parent = gui,
	}, { corner(8), stroke(themeColor(theme, "PanelStroke")), padding(0, 10) })
	self.TooltipText = text({
		Parent = self.Tooltip,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextSize = 12,
		FontFace = inter(Enum.FontWeight.Medium),
		TextColor3 = themeColor(theme, "Text"),
		ZIndex = 21,
	})

	-- Text-bearing panel stays a normal Frame: CanvasGroup rasterizes glyphs
	-- and produces blurry type on low graphics quality and nested scales.
	-- Only the dedicated Backdrop CanvasGroup needs rounded clipping.
	self.PanelHolder = create("Frame", {
		Name = "PanelHolder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(620, 380),
		Visible = false,
		ZIndex = 5,
		Parent = gui,
	})
	self.PanelShadow = shadow(self.PanelHolder, 34, 4, 10)
	self.Panel = create("Frame", {
		Name = "Panel",
		BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		Parent = self.PanelHolder,
	}, { corner(14) })
	self.PanelRise = create("UIScale", { Name = "Rise", Scale = 1, Parent = self.Panel })
	self.PanelOutline = create("Frame", {
		Name = "Outline",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6,
		Parent = self.PanelHolder,
	}, { corner(14) })
	self.PanelOutlineStroke = stroke(themeColor(theme, "PanelStroke"), 1, 1)
	self.PanelOutlineStroke.Parent = self.PanelOutline
	sheen(self.Panel, 16, theme, 7)
	self:_buildHeader()
	self.Pages = create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 57),
		-- Bottom inset keeps scrolled content inside the panel's rounded
		-- corners; a full-height rectangular clip would cut the lower arcs.
		Size = UDim2.new(1, 0, 1, -65),
		ClipsDescendants = true,
		Parent = self.Panel,
	})

    self:_setupPanelResize()

	-- Floating layers
	self.PinLayer = create("Frame", { Name = "Pins", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 8, Parent = gui })
	self.Toasts = create("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, topInset() + 6),
		Size = UDim2.new(0, 300, 1, -topInset() - 20),
		-- Keep notifications over the movable toolbar orb (ZIndex 36),
		-- without stealing input from modal overlays (ZIndex 98+).
		ZIndex = 42,
		Parent = gui,
	}, { list(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right) })
	-- Popup layer sits above Setup (95) but below Prompt (100). This
	-- matches OverlayStack priority even for API-driven nested opens.
	self.Overlay = create("Frame", { Name = "Overlay", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 98, Parent = gui })

	-- The touch toolbar control is a compact, movable orb.
	self.Restore = create("TextButton", {
		Name = "ToggleToolbar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 1, -34),
		Size = UDim2.fromOffset(44, 44),
		Text = "",
		AutoButtonColor = false,
		Active = true,
		Visible = UserInputService.TouchEnabled,
		ZIndex = 36,
		Parent = gui,
	}, { corner(100) })
	self:_setupToolbarOrb()

	self:_connect(UserInputService:GetPropertyChangedSignal("TouchEnabled"), function()
		self.Restore.Visible = UserInputService.TouchEnabled
		self:_setToolbarOrbSpin(UserInputService.TouchEnabled and not self._loading)
		if self._visible then self.DockHolder.Position = UDim2.new(0.5, 0, 1, -self:_dockBottom()) end
		if self._open then self:_fitPanel(self._open, false) end
	end)

	if options.Loading then
		self:_buildLoading(options.Loading)
	end

	self.CommandButton = create("TextButton", {
		Name = "OpenCommands", BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
		Size = UDim2.fromOffset(40, 40), LayoutOrder = 2000, Parent = self.SettingsGroup.Frame,
	}, { corner(9) })
	iconLabel("search", 19, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = self.CommandButton })
	self:_connect(self.CommandButton.MouseButton1Click, function() self:OpenCommandPalette() end)
	-- Initialize persisted AsterUI/FlowUI-style weather after the panel exists.
	-- None adds no particles or RenderStepped connection.
	if self:GetWeather() ~= "None" then
		self:_ensureWeather()
		self:_rebuildWeather()
	end
	self:_bindInput()
	if options.ConfigEncryption then
		local ok, err = self:SetConfigEncryption(options.ConfigEncryption)
		if not ok then self:_teardown() error("[RiftUI] " .. err, 2) end
		if saved and saved.EncryptConfigs ~= nil then self._encryptConfigs = saved.EncryptConfigs == true end
	end
	if options.ConfigServer then
		local ok, err = self:SetConfigServer(options.ConfigServer)
		if not ok then self:_teardown() error("[RiftUI] " .. err, 2) end
	end
	self:_bindDesignTokenShell()
	if options.Settings ~= false then
		self:_buildSettings()
	end
	table.insert(RiftUI.Hubs, self)
	queueSecureFont()
	registry[id] = self
	self:_registerSetupFlags()
	setState("Building", self.Name)
	task.defer(function()
		if self._destroyed then
			return
		end
		self:_loadingStep("Applying preferences", 0.45)
		if options.Setup ~= false and not (saved and saved.Completed) and not self._replaying then
			self:_afterLoading(function()
				task.delay(0.35, function()
					if not self._destroyed then
						self:OpenSetup()
					end
				end)
			end)
		end
		if options.Stealth then
			self:SetStealth(true)
		end
		if saved and type(saved.Studio) == "table" and saved.Studio.Background then
			self.Background = saved.Studio.Background
			self:_applyBackground()
		end
		if RiftUI.DeveloperMode and options.Settings ~= false then
			self:_buildDeveloper()
		end
		-- HUD pieces and language: the saved choice wins over the CreateHub default
		local prefs = self.SetupData or {}
		local function pref(key, default)
			if prefs[key] ~= nil then return prefs[key] end
			return default
		end
		-- HUD pieces come up with the toolbar, not over the loading card
		self:_afterLoading(function()
			if self._destroyed then return end
			if pref("Watermark", options.Watermark) and not self._watermark then self:SetWatermark(true, true) end
			if pref("KeybindList", options.KeybindList) then self:SetKeybindList(true, true) end
		end)
		local language = pref("Language", options.Language)
		if not language then
			pcall(function()
				local locale = string.lower(string.sub(game:GetService("LocalizationService").RobloxLocaleId, 1, 2))
				if RiftUI.Translations[locale] or (options.Translations or {})[locale] then language = locale end
			end)
		end
		if language and language ~= "en" then self:SetLanguage(language, true) end
		if next(self._requirements) then
			self:_loadingStep("Checking requirements", 0.65)
			self:RunRequirements()
		end
		self:_loadingStep("Loading config", 0.85)
		self:_autoload()
		if RiftUI.State == "Building" or RiftUI.State == "Reinitializing" then
			setState("Ready", self.Name)
		end
		if self._loading and not self._loading.Manual then
			self:FinishLoading()
		end
	end)
	return self
end

---------------------------------------------------------------- loading screen
--[[
	A small card that holds the screen while the hub builds. The dock stays down until it
	leaves, and anything that would open over it (setup, Hub:Open) waits its turn.
	Loading = true, or { Title, Subtitle, Icon, MinDuration, Manual }. With Manual = true the
	card stays until Hub:FinishLoading(); Hub:SetLoading(status, progress) drives it.
]]
-- The floating card the loading screen and the auth gate share: shadow, fading body,
-- outline and sheen, with a chip/title/subtitle head.
local function floatingCard(parent: Instance, theme, width: number, z: number)
	local holder = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 10),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = z,
		Parent = parent,
	})
	create("UISizeConstraint", { MaxSize = Vector2.new(width, 100000), Parent = holder })
	shadow(holder, 30, z, 8)
	local card = create("CanvasGroup", {
		Name = "Card",
		BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		GroupTransparency = 1,
		ZIndex = z + 1,
		Parent = holder,
	}, { corner(14), padding(16, 16, 16, 16), list(Enum.FillDirection.Vertical, 14) })
	local outline = create("Frame", { Name = "Outline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = z + 2, Parent = holder }, {
		corner(14),
		stroke(themeColor(theme, "PanelStroke"), 1, 1),
	})
	sheen(holder, 16, theme, z + 2)
	return holder, card, outline
end

local function cardHead(card: Instance, theme, title: string, subtitle: string?, icon: string?, z: number, rightInset: number?)
	local head = create("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), ZIndex = z, Parent = card })
	local chip = create("Frame", {
		Name = "Chip",
		BackgroundColor3 = themeColor(theme, "Tile"),
		Size = UDim2.fromOffset(32, 32),
		ZIndex = z,
		Parent = head,
	}, { corner(8), stroke(themeColor(theme, "TileStroke")) })
	if not hubMark(icon, 16, theme, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = z + 1, Parent = chip }) then
		text({ Parent = chip, Text = string.upper(string.sub(title, 1, 1)), FontFace = inter(Enum.FontWeight.SemiBold), Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = z + 1 })
	end
	local hasSub = type(subtitle) == "string" and subtitle ~= ""
	local inset = 44 + (rightInset or 0)
	text({ Parent = head, Name = "Title", Text = title, FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 14, Position = UDim2.fromOffset(44, hasSub and 0 or 8), Size = UDim2.new(1, -inset, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = z + 1 })
	if hasSub then
		text({ Parent = head, Name = "Subtitle", Text = subtitle, TextSize = 12, TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(44, 17), Size = UDim2.new(1, -inset, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = z + 1 })
	end
	return head
end

local function showCard(holder, card, outline)
	holder.Position = UDim2.fromScale(0.5, 0.5)
	tween(card, RISE, { GroupTransparency = 0 })
	tween(outline:FindFirstChildOfClass("UIStroke"), RISE, { Transparency = 0 })
end

local function hideCard(holder, card, outline)
	tween(outline:FindFirstChildOfClass("UIStroke"), FOLD, { Transparency = 1 })
	local shade = holder:FindFirstChild("Shadow")
	if shade then tween(shade, FOLD, { ImageTransparency = 1 }) end
	return tween(card, FOLD, { GroupTransparency = 1 })
end

function Hub:_buildLoading(o)
	o = type(o) == "table" and o or {}
	assert(o.MinDuration == nil or type(o.MinDuration) == "number", "Loading.MinDuration must be a number")
	local theme = self.Theme
	local state = { Manual = o.Manual == true, MinDuration = o.MinDuration or 1, Started = os.clock(), Progress = 0, Queue = {} }
	self._loading = state
	self.DockHolder.Visible = false
	self.Restore.Visible = false
	self:_setToolbarOrbSpin(false)
	local holder, card, outline = floatingCard(self.Gui, theme, 300, 95)
	holder.Name = "Loading"
	cardHead(card, theme, o.Title or self.Name, o.Subtitle or self.Subtitle, o.Icon or self.Icon, 96)
	local foot = create("Frame", { Name = "Status", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 2, ZIndex = 96, Parent = card })
	state.Status = text({ Parent = foot, Name = "Label", Text = self:T("Building interface"), TextSize = 11, TextColor3 = themeColor(theme, "SubText"), Size = UDim2.new(1, -44, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 97 })
	state.Percent = text({ Parent = foot, Name = "Percent", Text = "0%", FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromOffset(44, 14), ZIndex = 97 })
	local track = create("Frame", { Name = "Track", BackgroundColor3 = themeColor(theme, "Track"), BorderSizePixel = 0, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 3), ZIndex = 97, Parent = foot }, { corner(2) })
	state.Fill = create("Frame", { Name = "Fill", BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), ZIndex = 98, Parent = track }, { corner(2) })
	state.Holder, state.Card, state.Outline = holder, card, outline
	showCard(holder, card, outline)
	self:_loadingStep("Building interface", 0.2)
end

function Hub:_loadingStep(status: string, progress: number)
	local state = self._loading
	if state and not state.Manual then self:SetLoading(status, progress) end
end

-- Update the loading card. Progress is 0–1 and never moves backwards; omit it to keep the bar.
function Hub:SetLoading(status: string?, progress: number?)
	local state = self._loading
	if not state or state.Finishing then return end
	if type(status) == "string" then state.Status.Text = self:T(status) end
	if type(progress) == "number" then
		state.Progress = math.max(state.Progress, math.clamp(progress, 0, 1))
		state.Percent.Text = math.floor(state.Progress * 100 + 0.5) .. "%"
		tween(state.Fill, SETTLE, { Size = UDim2.fromScale(state.Progress, 1) })
	end
end

function Hub:IsLoading(): boolean
	return self._loading ~= nil
end

-- Run fn once the loading card has gone, or now if there isn't one.
function Hub:_afterLoading(fn)
	if self._loading then table.insert(self._loading.Queue, fn) else fn() end
end

function Hub:FinishLoading()
	local state = self._loading
	if not state or state.Finishing then return end
	state.Finishing = true
	state.Status.Text = self:T("Ready")
	state.Percent.Text = "100%"
	tween(state.Fill, SETTLE, { Size = UDim2.fromScale(1, 1) })
	task.spawn(function()
		-- a card that flashes for a frame reads as a glitch, so it stays at least MinDuration
		local wait = state.MinDuration - (os.clock() - state.Started)
		task.wait(math.max(0.25, wait))
		if self._destroyed then return end
		hideCard(state.Holder, state.Card, state.Outline).Completed:Wait()
		if self._destroyed then return end
		state.Holder:Destroy()
		self._loading = nil
		self.Restore.Visible = UserInputService.TouchEnabled
		self:_setToolbarOrbSpin(UserInputService.TouchEnabled)
		if self._visible then
			local holder, bottom = self.DockHolder, self:_dockBottom()
			holder.Position = UDim2.new(0.5, 0, 1, -bottom)
			holder.Visible = true
		end
		for _, fn in state.Queue do task.spawn(fn) end
	end)
end

---------------------------------------------------------------- auth gate
--[[
	Rift:CreateAuth asks for a key before any hub exists. The key goes to the author's server
	as a bearer token; a 2xx answer carries the hub script, which CreateAuth returns for the
	caller to loadstring. Anything already on the client can be edited, so the gate only
	protects what the server holds back: keep the hub itself on the server.

		local source, key = Rift:CreateAuth({ Name = "My Hub", Url = "https://auth.example.com/v1/script" })
		if not source then return end
		loadstring(source)()
]]
local AUTH_SCRIPT_LIMIT = 16 * 1024 * 1024

local function authHwid(): string?
	if typeof(gethwid) == "function" then
		local ok, id = pcall(gethwid)
		if ok and type(id) == "string" and id ~= "" then return id end
	end
	local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
	return ok and type(id) == "string" and id ~= "" and id or nil
end

-- A short, single-line reason from an error body: JSON { error } / { message }, or plain text.
local function authReason(body): string?
	if type(body) ~= "string" or body == "" or #body > 4096 then return nil end
	local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
	local reason
	if ok and type(data) == "table" then
		reason = data.error or data.message
	elseif not ok and not string.find(body, "<", 1, true) then
		reason = body
	end
	if type(reason) ~= "string" then return nil end
	reason = string.gsub(string.gsub(reason, "%c", " "), "^%s*(.-)%s*$", "%1")
	if reason == "" then return nil end
	return #reason > 140 and (string.sub(reason, 1, 140) .. "…") or reason
end

-- ok, scriptOrReason, retryable. Retryable failures (network, 429, 5xx) keep a saved key.
local function authCheck(o, key: string)
	if o.Request then
		local ok, passed, result = pcall(o.Request, key)
		if not ok then
			recordError(tostring(passed), nil, "auth")
			return false, "The key check failed. Try again.", true
		end
		if passed == true and type(result) == "string" and result ~= "" then return true, result end
		return false, type(result) == "string" and result ~= "" and result or "Invalid key.", passed == nil
	end
	local httpRequest = (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request)
	if not httpRequest then return false, "This executor can't make HTTP requests.", false end
	local headers = { Authorization = "Bearer " .. key, Accept = "text/plain, application/json" }
	if o.SendHwid then headers["X-Rift-Hwid"] = authHwid() end
	local ok, response = pcall(httpRequest, { Url = o.Url, Method = "GET", Headers = headers, Timeout = 20 })
	local status = ok and type(response) == "table" and tonumber(response.StatusCode) or 0
	if status == 0 then return false, "Couldn't reach the server. Check your connection and try again.", true end
	if status >= 200 and status < 300 then
		local body = response.Body
		if type(body) ~= "string" or body == "" then return false, "The server sent an empty script.", true end
		if #body > AUTH_SCRIPT_LIMIT then return false, "The server sent an oversized script.", false end
		return true, body
	end
	local retry = status == 429 or status >= 500
	local fallback = (status == 401 or status == 403) and "Invalid key."
		or status == 429 and "Too many attempts. Wait a moment, then try again."
		or ("The server returned HTTP " .. status .. ".")
	return false, (not retry and authReason(response.Body)) or fallback, retry
end

function RiftUI:CreateAuth(options)
	options = options or {}
	assert(type(options) == "table", "CreateAuth expects an options table")
	assert(options.Request == nil or type(options.Request) == "function", "Request must be a function")
	if not options.Request then
		local authority = type(options.Url) == "string" and string.match(options.Url, "^https://([^/%s?#]+)")
		assert(authority and not string.find(authority, "@", 1, true) and not string.find(options.Url, "[%s#]"), "CreateAuth needs an HTTPS Url without credentials, or a Request function")
	end
	local id = hubId(options)
	local name = options.Name or "Rift Hub"
	local saved = readSetup(id)
	local theme = buildTheme((saved and saved.Theme) or options.ThemeName or "Graphite", options.Theme)
	local remember = options.Remember ~= false and hasFS
	local keyPath = RiftUI.Folder .. "/" .. id .. "/auth.key"

	local gui = create("ScreenGui", { Name = "RiftAuth", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 110 })
	if typeof(protectgui) == "function" then pcall(protectgui, gui) end
	gui.Parent = guiParent()
	local holder, card, outline = floatingCard(gui, theme, 340, 10)
	holder.Name = "Auth"
	local head = cardHead(card, theme, options.Title or name, options.Subtitle or "Enter your key to continue", options.Icon or options.HubIcon, 11, 32)
	local close = create("TextButton", {
		Name = "Close", BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 4, 0.5, 0), Size = UDim2.fromOffset(28, 28), ZIndex = 12, Parent = head,
	}, { corner(7) })
	if not iconLabel("x", 15, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 13, Parent = close }) then
		text({ Parent = close, Text = "×", TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 13 })
	end
	close.MouseEnter:Connect(function() tween(close, FAST, { BackgroundTransparency = 0 }) end)
	close.MouseLeave:Connect(function() tween(close, FAST, { BackgroundTransparency = 1 }) end)
	if type(options.Note) == "string" and options.Note ~= "" then
		text({ Parent = card, Name = "Note", Text = options.Note, TextSize = 12, TextColor3 = themeColor(theme, "SubText"), TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 12 })
	end
	local field = create("Frame", { Name = "Field", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = 3, ZIndex = 11, Parent = card })
	local box = create("TextBox", {
		Name = "KeyBox", BackgroundColor3 = themeColor(theme, "Field"), Size = UDim2.new(1, 0, 0, 34),
		FontFace = MONO, TextSize = 12, TextColor3 = themeColor(theme, "Text"), Text = "",
		PlaceholderText = options.Placeholder or "Paste your key", PlaceholderColor3 = themeColor(theme, "Muted"),
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12, Parent = field,
	}, { corner(7), padding(0, 10) })
	local boxStroke = stroke(themeColor(theme, "FieldStroke"))
	boxStroke.Parent = box
	local status = text({ Parent = field, Name = "Status", Text = "", TextSize = 11, TextColor3 = themeColor(theme, "Muted"), Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 12 })
	local buttons = create("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 4, ZIndex = 11, Parent = card })
	local links = create("Frame", { Name = "Links", BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0), ZIndex = 11, Parent = buttons }, {
		list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
	})
	local function button(label: string, primary: boolean, parent: Instance, order: number?)
		local b = create("TextButton", {
			Name = label, BackgroundColor3 = themeColor(theme, primary and "Accent" or "Tile"), Text = label,
			FontFace = inter(Enum.FontWeight.Medium), TextSize = 13, TextColor3 = themeColor(theme, primary and "AccentText" or "Text"),
			AutoButtonColor = false, Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order or 0, ZIndex = 12, Parent = parent,
		}, { corner(8), padding(0, 12) })
		if not primary then
			stroke(themeColor(theme, "TileStroke")).Parent = b
			b.MouseEnter:Connect(function() tween(b, FAST, { BackgroundColor3 = themeColor(theme, "TileHover") }) end)
			b.MouseLeave:Connect(function() tween(b, FAST, { BackgroundColor3 = themeColor(theme, "Tile") }) end)
		end
		return b
	end
	local submit = button("Continue", true, buttons)
	submit.AnchorPoint = Vector2.new(1, 0)
	submit.Position = UDim2.fromScale(1, 0)
	submit.Size = UDim2.fromOffset(100, 32)
	submit.AutomaticSize = Enum.AutomaticSize.None

	local function say(message: string, tone: string?)
		status.Text = message
		setThemed(status, "TextColor3", themeColor(theme, tone or "Muted"))
	end
	local function copyLink(url: string, what: string)
		if typeof(setclipboard) == "function" and pcall(setclipboard, url) then
			say(what .. " link copied. Open it in your browser.", "Success")
		else
			say(url, "SubText")
		end
	end
	if type(options.GetKeyUrl) == "string" and options.GetKeyUrl ~= "" then
		button("Get key", false, links, 1).MouseButton1Click:Connect(function() copyLink(options.GetKeyUrl, "Key") end)
	end
	if type(options.Discord) == "string" and options.Discord ~= "" then
		button("Discord", false, links, 2).MouseButton1Click:Connect(function() copyLink(options.Discord, "Discord") end)
	end

	local finished, result, acceptedKey, reason = false, nil, nil, nil
	local busy = false
	local function shake()
		local x = { 7, -6, 4, -2, 0 }
		task.spawn(function()
			for _, dx in x do
				holder.Position = UDim2.new(0.5, dx, 0.5, 0)
				task.wait(0.035)
			end
		end)
		tween(boxStroke, FAST, { Color = themeColor(theme, "Danger") })
	end
	local function attempt(key: string, fromFile: boolean)
		if busy or finished then return end
		key = string.gsub(key or "", "^%s*(.-)%s*$", "%1")
		if key == "" then say("Enter your key.", "Danger") shake() return end
		if #key > 512 or string.find(key, "%c") then say("That key isn't valid.", "Danger") shake() return end
		busy = true
		box.TextEditable = false
		submit.Text = "Checking…"
		say(fromFile and "Checking your saved key…" or "Checking key…")
		tween(boxStroke, FAST, { Color = themeColor(theme, "FieldStroke") })
		local ok, value, retry = authCheck(options, key)
		busy = false
		if finished or not gui.Parent then return end
		box.TextEditable = true
		submit.Text = "Continue"
		if ok then
			say("Key accepted. Loading " .. name .. "…", "Success")
			tween(boxStroke, FAST, { Color = themeColor(theme, "Success") })
			if remember then
				pcall(function()
					ensureFolder(RiftUI.Folder) ensureFolder(RiftUI.Folder .. "/" .. id)
					writefile(keyPath, key)
				end)
			end
			result, acceptedKey = value, key
			task.wait(0.35)
			finished = true
		else
			-- a rejected saved key is forgotten; one that only hit a network error is kept
			if fromFile and not retry and typeof(delfile) == "function" then pcall(delfile, keyPath) end
			say(value, "Danger")
			shake()
		end
	end
	submit.MouseButton1Click:Connect(function() task.spawn(attempt, box.Text, false) end)
	box.FocusLost:Connect(function(enter) if enter then task.spawn(attempt, box.Text, false) end end)
	box.Focused:Connect(function() if not busy then tween(boxStroke, FAST, { Color = themeColor(theme, "SubText") }) end end)
	close.MouseButton1Click:Connect(function()
		if finished then return end
		reason, finished = "closed", true
	end)

	showCard(holder, card, outline)
	if remember then
		local ok, stored = pcall(function() return isfile(keyPath) and readfile(keyPath) or nil end)
		if ok and type(stored) == "string" and stored ~= "" then
			box.Text = stored
			task.spawn(attempt, stored, true)
		end
	end
	while not finished and gui.Parent do task.wait() end
	if not finished then reason = "closed" end
	if gui.Parent then
		hideCard(holder, card, outline).Completed:Wait()
		gui:Destroy()
	end
	if result then return result, acceptedKey end
	return nil, reason or "closed"
end

-- Forget the key CreateAuth saved for a hub, e.g. from a "Log out" button.
function RiftUI:ClearAuthKey(options)
	local id = hubId(type(options) == "string" and { Id = options } or options or {})
	if hasFS and typeof(delfile) == "function" then
		pcall(delfile, RiftUI.Folder .. "/" .. id .. "/auth.key")
	end
end

---------------------------------------------------------------- developer-defined requirements
local function requirementIds(required)
	if required == nil then return {} end
	if type(required) == "string" then return { required } end
	assert(type(required) == "table", "Requires must be a requirement ID or a list of IDs")
	local ids, seen = {}, {}
	for _, id in required do
		assert(type(id) == "string" and id ~= "", "Requires must contain requirement IDs")
		if not seen[id] then seen[id] = true table.insert(ids, id) end
	end
	return ids
end

local function mergedRequirements(parent, own)
	local out, seen = {}, {}
	for _, list in { requirementIds(parent), requirementIds(own) } do
		for _, id in list do if not seen[id] then seen[id] = true table.insert(out, id) end end
	end
	return out
end

function Hub:_initRequirements(definitions)
	self._requirements, self._requirementResults, self._requirementRuns = {}, {}, {}
	self._requiredControls, self._requirementWatchers, self._requirementThreads = {}, {}, {}
	assert(definitions == nil or type(definitions) == "table", "Requirements must be a table of developer tests")
	for id, spec in definitions or {} do
		assert(type(id) == "string" and id ~= "", "Requirements must use named IDs")
		if type(spec) == "function" then spec = { Test = spec } end
		assert(type(spec) == "table" and type(spec.Test) == "function", "Requirement " .. id .. " needs a developer-defined Test function")
		assert(spec.Name == nil or type(spec.Name) == "string", "Requirement Name must be a string")
		assert(spec.Message == nil or type(spec.Message) == "string", "Requirement Message must be a string")
		local timeout = spec.Timeout or 5
		assert(type(timeout) == "number" and timeout >= 0.1 and timeout <= 30, "Requirement Timeout must be 0.1–30 seconds")
		self._requirements[id] = { Test = spec.Test, Name = spec.Name or id, Message = spec.Message, Timeout = timeout }
		self._requirementResults[id] = { Id = id, Name = spec.Name or id, Status = "pending", Passed = false, Message = "Not checked yet" }
	end
end

function Hub:CanUse(required)
	for _, id in requirementIds(required) do
		local result = self._requirementResults[id]
		if not result then return false, "Unknown requirement: " .. id end
		if not result.Passed then
			if result.Status == "pending" then return false, "Checking " .. result.Name .. "…" end
			return false, result.Message or (result.Name .. " is unavailable")
		end
	end
	return true
end

function Hub:GetRequirement(id)
	local result = self._requirementResults[id]
	return result and table.clone(result) or nil
end

function Hub:OnRequirementsChanged(callback)
	assert(type(callback) == "function", "callback must be a function")
	local watcher = { Callback = callback, Connected = true }
	table.insert(self._requirementWatchers, watcher)
	return { Disconnect = function() watcher.Connected = false end }
end

function Hub:_requirementsChanged()
	if self._destroyed then return end
	for _, control in self._requiredControls do
		if control.Frame.Parent then
			local allowed, reason = self:CanUse(control.Requires)
			control.Available, control.RequirementMessage = allowed, reason
			self:_syncLockOverlay(control)
			if not allowed then
				-- A popup opened before a test changed must not bypass the new gate.
				if self._popup then
					local anchor = self._popup.Anchor
					if anchor and anchor:IsDescendantOf(control.Frame) then self:_closePopup() end
				end
			else
				if control._requirementRestore then self:_restoreRequiredControl(control) end
				if control._pendingRequirementDefault then
					control._pendingRequirementDefault = nil
					if control.Type == "Toggle" and control.Value then control:_emit(true) end
				end
			end
		end
	end
	self:_keybindsChanged()
	for _, watcher in self._requirementWatchers do
		if watcher.Connected then
			local snapshot = {}
			for id, result in self._requirementResults do snapshot[id] = table.clone(result) end
			task.spawn(function()
				local ok, err = pcall(watcher.Callback, snapshot)
				if not ok then recordError(tostring(err), nil, "requirements changed") end
			end)
		end
	end
end

function Hub:RunRequirement(id)
	local spec = self._requirements[id]
	if not spec then return { Id = id, Name = id, Passed = false, Status = "failed", Message = "Unknown requirement: " .. tostring(id) } end
	if self._requirementThreads[id] then pcall(task.cancel, self._requirementThreads[id]) end
	local run = (self._requirementRuns[id] or 0) + 1
	self._requirementRuns[id] = run
	self._requirementResults[id] = { Id = id, Name = spec.Name, Passed = false, Status = "pending", Message = "Checking…" }
	self:_requirementsChanged()
	local finished, success, passed, message = false, false, false, nil
	local thread = task.spawn(function()
		success, passed, message = pcall(spec.Test, self)
		finished = true
	end)
	self._requirementThreads[id] = thread
	local started = os.clock()
	while not finished and not self._destroyed and self._requirementRuns[id] == run and os.clock() - started < spec.Timeout do task.wait() end
	if self._destroyed or self._requirementRuns[id] ~= run then pcall(task.cancel, thread) return self:GetRequirement(id) end
	if not finished then pcall(task.cancel, thread) end
	self._requirementThreads[id] = nil
	local result = { Id = id, Name = spec.Name, Passed = finished and success and passed == true, Status = "failed" }
	if not finished then
		result.Status, result.Message = "timeout", spec.Name .. " test timed out"
	elseif not success then
		result.Message = spec.Message or (spec.Name .. " test raised an error")
		-- Test errors belong to the developer. Keep them in the result, not a generic VM failure.
		result.Error = tostring(passed)
	elseif passed ~= true then
		result.Message = type(message) == "string" and message or spec.Message or (spec.Name .. " is unavailable")
	else
		result.Status, result.Message = "passed", type(message) == "string" and message or "Available"
	end
	self._requirementResults[id] = result
	self:_requirementsChanged()
	return table.clone(result)
end

function Hub:RunRequirements()
	self._requirementBatch = (self._requirementBatch or 0) + 1
	local batch = self._requirementBatch
	local ids = {}
	for id in self._requirements do table.insert(ids, id) end
	table.sort(ids)
	-- Mark the whole set pending so a recheck cannot use stale passing results.
	for _, id in ids do
		self._requirementRuns[id] = (self._requirementRuns[id] or 0) + 1
		self._requirementResults[id] = { Id = id, Name = self._requirements[id].Name, Passed = false, Status = "pending", Message = "Checking…" }
	end
	self:_requirementsChanged()
	local results = {}
	for _, id in ids do
		if self._destroyed or batch ~= self._requirementBatch then break end
		results[id] = self:RunRequirement(id)
	end
	return results
end

function Hub:Guard(required, callback)
	local ids = requirementIds(required)
	assert(type(callback) == "function", "Guard needs a callback")
	return function(...)
		local allowed, reason = self:CanUse(ids)
		if not allowed then return false, reason end
		return callback(...)
	end
end

function Hub:_finishRequiredControl(control)
    -- One availability surface serves explicit locks and developer requirements.
    -- A lock must not substitute a notification or hide the underlying label.
    if #control.Requires > 0 then
        table.insert(self._requiredControls, control)
    end
    self:_syncLockOverlay(control)
    local interactive = not ({
        Label = true, Paragraph = true, Info = true, InfoGrid = true,
        InfoList = true, DataTable = true, StatusList = true,
        EventTimeline = true, TreeView = true, ViewportPreview = true,
        Progress = true, Stat = true, Sparkline = true, Console = true,
    })[control.Type]
    if interactive and type(control.Set) == "function" and not control._availabilityWrapped then
        local originalSet = control.Set
        control.Set = function(c, ...)
            local allowed, reason = c:IsAvailable()
            if not allowed then return false, reason end
            return originalSet(c, ...)
        end
        control._availabilityWrapped = true
    end
    return control
end

function Hub:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

-- SPDX-License-Identifier: MPL-2.0
-- Per-hub pointer capture, touch cancellation and scroll ownership (Oasis-inspired).
local function bindPointerDrag(hub, handle: GuiObject, callbacks, scoped: boolean?)
    local pointer: InputObject? = nil
    local moveConn, endConn, stateConn, destroyConn
    local handleConn
    local locked = {}
    local binding = {}

    local function disconnectActive()
        if moveConn then moveConn:Disconnect() moveConn = nil end
        if endConn then endConn:Disconnect() endConn = nil end
        if stateConn then stateConn:Disconnect() stateConn = nil end
        for frame, previous in locked do
            pcall(function() frame.ScrollingEnabled = previous end)
            locked[frame] = nil
        end
    end

    local function stop(cancelled: boolean)
        if not pointer then return end
        pointer = nil
        disconnectActive()
        if hub._capturedDrag == binding then hub._capturedDrag = nil end
        if hub._activeDrags then hub._activeDrags[binding] = nil end
        if callbacks.End then
            local ok, err = pcall(callbacks.End, cancelled)
            if not ok then warn('[RiftUI] drag end: ' .. tostring(err)) end
        end
    end

    local function begin(input: InputObject)
        if hub._destroyed or pointer or not isPointer(input) then return end
        if hub._capturedDrag and hub._capturedDrag ~= binding then return end
        pointer = input
        hub._capturedDrag = binding
        hub._activeDrags = hub._activeDrags or {}
        hub._activeDrags[binding] = true
        if input.UserInputType == Enum.UserInputType.Touch then
            local node = handle.Parent
            while node and not node:IsA('LayerCollector') do
                if node:IsA('ScrollingFrame') then
                    locked[node] = node.ScrollingEnabled
                    node.ScrollingEnabled = false
                end
                node = node.Parent
            end
            stateConn = input:GetPropertyChangedSignal('UserInputState'):Connect(function()
                local state = input.UserInputState
                if state == Enum.UserInputState.Cancel or state == Enum.UserInputState.End then
                    stop(state == Enum.UserInputState.Cancel)
                end
            end)
        end
        if callbacks.Start then
            local ok, err = pcall(callbacks.Start, input)
            if not ok then
                warn('[RiftUI] drag start: ' .. tostring(err))
                stop(true)
                return
            end
        end
        if not pointer then return end
        moveConn = UserInputService.InputChanged:Connect(function(changed)
            if not pointer or hub._destroyed then return end
            local touch = pointer.UserInputType == Enum.UserInputType.Touch
            if (touch and changed == pointer) or (not touch and changed.UserInputType == Enum.UserInputType.MouseMovement) then
                if callbacks.Move then
                    local ok, err = pcall(callbacks.Move, changed)
                    if not ok then
                        warn('[RiftUI] drag move: ' .. tostring(err))
                        stop(true)
                    end
                end
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(ended)
            if not pointer then return end
            -- Touch must match the captured InputObject; mouse release is a separate event.
            local touch = pointer.UserInputType == Enum.UserInputType.Touch
            if (touch and ended == pointer) or
                (not touch and ended.UserInputType == Enum.UserInputType.MouseButton1) then
                stop(false)
            end
        end)
    end

    handleConn = scoped and handle.InputBegan:Connect(begin) or hub:_connect(handle.InputBegan, begin)
    function binding:Disconnect()
        stop(true)
        if handleConn then handleConn:Disconnect() handleConn = nil end
        if destroyConn then destroyConn:Disconnect() destroyConn = nil end
    end
    binding.Cancel = binding.Disconnect
    destroyConn = handle.Destroying:Connect(function() binding:Disconnect() end)
    return binding
end
-- SPDX-License-Identifier: MPL-2.0
-- Invisible bottom-right resize hit target, with independent geometry per page.
-- All touch/mouse capture continues to use the hub-owned PointerDrag manager.
do
    function Hub:_panelSizeKey(tab)
        local page = tab and self:_contentTab(tab)
        if not page then return nil end
        local primary = page.ParentTab or page
        local group = primary.Group
        -- Include primary tab and group to distinguish identical child names.
        local prefix = tostring(group and group.Name or "Main") .. "/" .. tostring(primary.Name)
        if page.IsSubTab then
            return prefix .. "/sub/" .. tostring(page.Name)
        end
        return prefix .. "/main"
    end

    function Hub:_panelSizeFor(tab)
        local key = self:_panelSizeKey(tab)
        local size = key and self._panelSizes and self._panelSizes[key]
        if type(size) ~= "table" then return nil end
        local w, h = tonumber(size.Width), tonumber(size.Height)
        if not w or not h or w ~= w or h ~= h then return nil end
        return { Width = w, Height = h }
    end

    function Hub:_savePanelSize(key)
        if not key or not self._panelSizes then return end
        self:_savePref("PanelSizes", table.clone(self._panelSizes))
    end

    function Hub:GetPanelSize()
        if self.PanelHolder then
            return Vector2.new(self.PanelHolder.Size.X.Offset, self.PanelHolder.Size.Y.Offset)
        end
        return Vector2.new(620, 380)
    end

    function Hub:SetPanelSize(width, height, save)
        if self._destroyed then return false end
        if type(width) ~= "number" or type(height) ~= "number"
            or width ~= width or height ~= height then return false end
        local page = self._open or self.Tabs[1]
        local key = self:_panelSizeKey(page)
        if not key then return false end
        local vp = viewport() / math.max(self._scale, .01)
        local maxWidth = math.max(240, vp.X - 24)
        local maxHeight = math.max(160, vp.Y - topInset() / self._scale
            - self:_dockBottom() - 78)
        local size = {
            Width = math.clamp(width, math.min(340, maxWidth), maxWidth),
            Height = math.clamp(height, math.min(260, maxHeight), maxHeight),
        }
        self._panelSizes = self._panelSizes or {}
        self._panelSizes[key] = size
        if self._open then self:_fitPanel(self._open, false) end
        if save ~= false then self:_savePanelSize(key) end
        return true
    end

    function Hub:ResetPanelSize()
        if self._destroyed then return end
        local key = self:_panelSizeKey(self._open or self.Tabs[1])
        if not key then return end
        self._panelSizes = self._panelSizes or {}
        self._panelSizes[key] = nil
        self:_savePanelSize(key)
        if self._open then self:_fitPanel(self._open, false) end
    end

    function Hub:_setupPanelResize()
        if self.Options.Resizable == false then return end
        -- The 34x34 target remains draggable but has NO grooves or visual mark.
        local grip = create("TextButton", {
            Name = "PanelResizeGrip", BackgroundTransparency = 1, TextTransparency = 1,
            Text = "", AutoButtonColor = false, Active = true,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.fromOffset(34, 34),
            ZIndex = 19, Parent = self.PanelHolder,
        })
        local startPoint, startSize, startPage, startKey
        self._panelResizeGrip = grip
        self._panelResizeBinding = bindPointerDrag(self, grip, {
            Start = function(input)
                if not self._open then return end
                Motion.cancel(self, "panel-geometry")
                startPage = self:_contentTab(self._open)
                startKey = self:_panelSizeKey(startPage)
                startPoint = Vector2.new(input.Position.X, input.Position.Y)
                startSize = self:GetPanelSize()
            end,
            Move = function(input)
                if not startPoint or not startSize or not self._open
                    or startPage ~= self:_contentTab(self._open) then return end
                local delta = (Vector2.new(input.Position.X, input.Position.Y) -
                    startPoint) / math.max(self._scale, .01)
                -- Center anchored: double delta to keep the bottom-right corner
                -- under the drag pointer. Refit only the active page.
                self:SetPanelSize(startSize.X + 2 * delta.X,
                    startSize.Y + 2 * delta.Y, false)
            end,
            End = function(cancelled)
                if startPoint and not cancelled and startKey
                    and self:_panelSizeKey(self._open) == startKey
                    and self._panelSizes and self._panelSizes[startKey] then
                    self:_savePanelSize(startKey)
                end
                startPoint, startSize, startPage, startKey = nil, nil, nil, nil
            end,
        }, true)
    end
end


-- SPDX-License-Identifier: MPL-2.0
-- Coalesce continuous input callbacks, leaving state/UI updates immediate.
local continuousControls = { Slider = true, RangeSlider = true, ColorPicker = true }
local queuedControlCallbacks = setmetatable({}, { __mode = 'k' })

local function scheduleControlCallback(control, args, callback)
    local hub = control.Section.Hub
    if hub._destroyed then return end
    if not continuousControls[control.Type] then
        task.spawn(function()
            if not hub._destroyed then callback(args) end
        end)
        return
    end
    local pending = queuedControlCallbacks[control]
    if pending then pending.Args = args return end
    pending = { Args = args }
    queuedControlCallbacks[control] = pending
    task.defer(function()
        if queuedControlCallbacks[control] ~= pending then return end
        queuedControlCallbacks[control] = nil
        if not hub._destroyed then callback(pending.Args) end
    end)
end

local function cancelHubCallbacks(hub)
    for control in queuedControlCallbacks do
        if control.Section.Hub == hub then
            queuedControlCallbacks[control] = nil
        end
    end
end


do
-- SPDX-License-Identifier: MPL-2.0
-- RelaxUI control themes: default preserves the original RiftUI controls;
-- Rounded uses independent graphics/indicator motion, never text-container scaling.
-- Skins attach after each control is constructed, so flags, callbacks and saved
-- values remain on the original control instances. Runtime switching is reversible.

RiftUI.ControlThemes = { "Default", "Rounded" }
local CONTROL_SKIN_TWEEN = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local CONTROL_SKIN_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function skinTween(inst, goals, animate)
    if not inst then return end
    if animate then
        tween(inst, CONTROL_SKIN_TWEEN, goals)
    else
        for prop, value in goals do inst[prop] = value end
    end
end

local function skinCorner(inst, radius)
    if not inst then return end
    local c = inst:FindFirstChildOfClass("UICorner")
    if c then c.CornerRadius = UDim.new(0, radius) end
end

local function skinRow(row, height)
    if row.Size.Y.Offset ~= height then
        row.Size = UDim2.new(1, 0, 0, height)
    end
end

local function skinNode(row, name)
    return row:FindFirstChild(name, true)
end

local function skinSource(control)
    local hub, row, kind = control.Section.Hub, control.Frame, control.Type
    local theme = hub.Theme

    if kind == "Toggle" then
        local box = skinNode(row, "Check")
        if not box then return nil end
        local mark = box:FindFirstChildWhichIsA("ImageLabel")
        local pop = box:FindFirstChildOfClass("UIScale")
        local labels = skinNode(row, "Labels")
        local knob = create("Frame", {
            Name = "RoundedThumb",
            BackgroundColor3 = themeColor(theme, "Text"),
            BorderSizePixel = 0, Visible = false,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(13, 13),
            ZIndex = box.ZIndex + 1, Parent = box,
        }, { corner(7) })
        local lastValue
        return function(rounded, changed, animate)
            if changed then
                if pop then cancelMotion(pop); pop.Scale = 1 end
                box.Size = UDim2.fromOffset(rounded and 30 or 16, rounded and 18 or 16)
                skinCorner(box, rounded and 9 or 4)
                if labels then
                    labels.Size = UDim2.new(1, rounded and -43 or -32, 1, 0)
                end
                knob.Visible = rounded
                if mark then
                    mark.Visible = not rounded
                    mark.ImageTransparency = control.Value and 0 or 1
                end
            end
            if rounded then
                local on = control.Value == true
                -- Thumb moves independently; no scale on text-bearing containers.
                local goal = UDim2.new(0, on and 15 or 2, 0.5, 0)
                if changed or on ~= lastValue then
                    skinTween(knob, { Position = goal }, animate and not changed)
                end
                setThemed(knob, "BackgroundColor3", themeColor(theme, on and "AccentText" or "Text"))
            end
            lastValue = control.Value == true
        end
    end

    if kind == "Slider" or kind == "RangeSlider" then
        local track = skinNode(row, "Track")
        if not track then return nil end
        local fill = track:FindFirstChild("Fill")
        local hit = skinNode(row, "Hit")
        local knob = kind == "Slider" and track:FindFirstChild("Notch") or nil
        local low = kind == "RangeSlider" and track:FindFirstChild("Low") or nil
        local high = kind == "RangeSlider" and track:FindFirstChild("High") or nil
        local bubble
        local bubbleText
        local dragging = false
        local hideVersion = 0
        if kind == "Slider" then
            bubble = create("CanvasGroup", {
                Name = "RoundedValueBubble",
                Size = UDim2.fromOffset(42, 18),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromOffset(24, 34),
                BackgroundColor3 = themeColor(theme, "TileActive"),
                GroupTransparency = 1, Visible = false,
                ZIndex = 6, Parent = row,
            }, { corner(8), stroke(themeColor(theme, "TileActiveStroke")) })
            bubbleText = text({
                Parent = bubble, Name = "BubbleValue",
                Text = "", TextSize = 11, FontFace = MONO,
                TextColor3 = themeColor(theme, "Text"),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Size = UDim2.fromScale(1, 1), ZIndex = 7,
            })
        end
        local function updateBubble()
            if not bubble or not bubbleText then return end
            local min, max = control.Min or 0, control.Max or 100
            local ratio = max > min and math.clamp((control.Value - min) / (max - min), 0, 1) or 0
            local available = math.max(44, row.AbsoluteSize.X / math.max(hub._scale, .01))
            local x = math.clamp(ratio * available, 22, math.max(22, available - 22))
            bubble.Position = UDim2.fromOffset(math.floor(x + 0.5), 34)
            bubbleText.Text = formatNumber(control.Value, control.Step or 1)
        end
        if kind == "Slider" then
            -- The actual slider's bindPointerDrag is the authoritative lifecycle.
            -- A separate InputBegan/Ended pair previously leaked a floating
            -- bubble after pointer release and could move it above the title.
            control._skinDrag = function(on)
                if hub._destroyed or not bubble then return end
                hideVersion += 1
                local ticket = hideVersion
                dragging = on == true and hub:GetControlTheme() == "Rounded"
                if dragging then
                    updateBubble()
                    bubble.Visible = true
                    skinTween(bubble, { GroupTransparency = 0 }, true)
                else
                    skinTween(bubble, { GroupTransparency = 1 }, true)
                    task.delay(CONTROL_SKIN_FAST.Time + .03, function()
                        if not hub._destroyed and ticket == hideVersion and not dragging then
                            bubble.Visible = false
                        end
                    end)
                end
            end
            hub:_connect(row.Destroying, function()
                hideVersion += 1
                dragging = false
            end)
        end
        return function(rounded, changed, animate)
            if changed then
                -- Keep the readout/title in their original position and use a
                -- comfortably sized, non-overlapping track and thumb.
                skinRow(row, rounded and 52 or 46)
                skinTween(track, {
                    Position = UDim2.fromOffset(0, rounded and 39 or 34),
                    Size = UDim2.new(1, 0, 0, rounded and 5 or 2),
                }, animate)
                skinCorner(track, rounded and 3 or 1)
                skinCorner(fill, rounded and 3 or 1)
                if hit then
                    hit.Position = UDim2.fromOffset(-6, rounded and 27 or 24)
                    hit.Size = UDim2.new(1, 12, 0, rounded and 27 or 22)
                end
                for _, handle in { knob, low, high } do
                    if handle then
                        skinTween(handle, { Size = UDim2.fromOffset(rounded and 12 or 4, rounded and 12 or 14) }, animate)
                        skinCorner(handle, rounded and 6 or 2)
                    end
                end
                if bubble and not rounded then
                    hideVersion += 1
                    dragging = false
                    cancelMotion(bubble)
                    bubble.Visible = false
                    bubble.GroupTransparency = 1
                end
            end
            if rounded and bubble and dragging then updateBubble() end
        end
    end

    if kind == "Button" then
        local button = skinNode(row, "Button")
        if not button then return nil end
        local press = button:FindFirstChildOfClass("UIScale")
        local base = button.BackgroundColor3
        control._skinPress = function(down)
            if hub:GetControlTheme() ~= "Rounded" then return end
            skinTween(button, {
                BackgroundColor3 = down and themeColor(theme, "TileActive") or base,
            }, true)
        end
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 38 or 36)
            skinTween(button, { Size = UDim2.new(1, 0, 0, rounded and 30 or 28) }, animate)
            skinCorner(button, hub:GetToken(rounded and "Radius.M" or "Radius.XS"))
            -- No 1px highlight stripe or full-button UIScale: both made this
            -- widget look detached and caused its caption to rasterize poorly.
            if press then cancelMotion(press); press.Scale = 1 end
            local border = button:FindFirstChildOfClass("UIStroke")
            if border then border.Thickness = rounded and 1 or 1 end
        end
    end

    if kind == "Dropdown" or kind == "PlayerPicker" or kind == "Keybind" then
        local chip = skinNode(row, kind == "Keybind" and "Key" or "Chip")
        if not chip then return nil end
        local originalHeight = chip.Size.Y.Offset
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 40 or 34)
            skinTween(chip, {
                Size = UDim2.new(chip.Size.X.Scale, chip.Size.X.Offset, 0, rounded and 30 or originalHeight),
            }, animate)
            skinCorner(chip, hub:GetToken(rounded and "Radius.M" or "Radius.XS"))
            local border = chip:FindFirstChildOfClass("UIStroke")
            if border then border.Thickness = rounded and 1.15 or 1 end
            local limits = chip:FindFirstChildOfClass("UISizeConstraint")
            if limits then
                if limits.MaxSize.X < 10000 then
                    limits.MaxSize = Vector2.new(limits.MaxSize.X, rounded and 30 or originalHeight)
                end
                if limits.MinSize.X > 0 then
                    limits.MinSize = Vector2.new(limits.MinSize.X, rounded and 30 or originalHeight)
                end
            end
        end
    end

    if kind == "Segmented" then
        local track, pill = skinNode(row, "Track"), skinNode(row, "Pill")
        if not track or not pill then return nil end
        local labeled = skinNode(row, "Title") ~= nil
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, labeled and (rounded and 66 or 58) or (rounded and 42 or 34))
            skinTween(track, { Size = UDim2.new(1, 0, 0, rounded and 36 or 28) }, animate)
            skinCorner(track, rounded and 13 or 7)
            skinCorner(pill, rounded and 11 or 5)
            local border = track:FindFirstChildOfClass("UIStroke")
            if border then border.Thickness = rounded and 1.15 or 1 end
        end
    end

    if kind == "Input" then
        local box = skinNode(row, "Box")
        if not box then return nil end
        local originalHeight = box.Size.Y.Offset
        local originalRow = row.Size.Y.Offset
        local focus = create("Frame", {
            Name = "RoundedFocusIndicator",
            BackgroundColor3 = themeColor(theme, "Accent"),
            BackgroundTransparency = .2,
            BorderSizePixel = 0, Visible = false,
            AnchorPoint = Vector2.new(.5, 1),
            Position = UDim2.new(.5, 0, 1, -2),
            Size = UDim2.new(1, -20, 0, 2),
            ZIndex = box.ZIndex + 1, Parent = box,
        }, { corner(1) })
        hub:_connect(box.Focused, function()
            if hub:GetControlTheme() == "Rounded" then focus.Visible = true end
        end)
        hub:_connect(box.FocusLost, function() focus.Visible = false end)
        return function(rounded, changed, animate)
            if not changed then return end
            local height = rounded and originalHeight + 6 or originalHeight
            skinRow(row, rounded and originalRow + 8 or originalRow)
            skinTween(box, { Size = UDim2.new(1, 0, 0, height) }, animate)
            skinCorner(box, hub:GetToken(rounded and "Radius.M" or "Radius.XS"))
            focus.Visible = rounded and box:IsFocused()
        end
    end

    if kind == "ColorPicker" then
        local swatch = skinNode(row, "Swatch")
        if not swatch then return nil end
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 40 or 34)
            skinTween(swatch, { Size = UDim2.fromOffset(rounded and 44 or 36, rounded and 26 or 20) }, animate)
            skinCorner(swatch, hub:GetToken(rounded and "Radius.M" or "Radius.XS"))
        end
    end

    if kind == "Stepper" then
        local box = skinNode(row, "Stepper")
        if not box then return nil end
        local labels = skinNode(row, "Labels")
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, rounded and 40 or 34)
            skinTween(box, { Size = UDim2.fromOffset(rounded and 104 or 92, rounded and 30 or 24) }, animate)
            skinCorner(box, hub:GetToken(rounded and "Radius.M" or "Radius.XS"))
            if labels then labels.Size = UDim2.new(1, rounded and -119 or -104, 1, 0) end
            for _, name in { "Decrease", "Increase" } do
                skinCorner(box:FindFirstChild(name), rounded and 13 or 6)
            end
        end
    end

    if kind == "Progress" then
        local bar = skinNode(row, "Bar")
        if not bar then return nil end
        local titled = skinNode(row, "Title") ~= nil
        return function(rounded, changed, animate)
            if not changed then return end
            skinRow(row, titled and (rounded and 46 or 42) or (rounded and 26 or 22))
            skinTween(bar, { Size = UDim2.new(1, 0, 0, rounded and 9 or 6) }, animate)
            for _, child in bar:GetDescendants() do
                if child:IsA("Frame") and child.Name ~= "Bar" then
                    skinCorner(child, rounded and 5 or (child.Name == "Segment" and 2 or 3))
                end
            end
        end
    end
    return nil
end

function Hub:GetControlTheme()
    return self._controlTheme == "Rounded" and "Rounded" or "Default"
end

function Hub:_attachControlTheme(control)
    -- Defer to the end of control construction: visual objects and Set() now exist.
    task.defer(function()
        if self._destroyed or not control.Frame.Parent then return end
        local style = skinSource(control)
        if not style then return end
        self._skinEntries = self._skinEntries or setmetatable({}, { __mode = "k" })
        local current
        local function refresh(animate, force)
            if self._destroyed or not control.Frame.Parent then return end
            local nextTheme = self:GetControlTheme()
            local changed = nextTheme ~= current or force == true
            current = nextTheme
            style(nextTheme == "Rounded", changed, animate)
        end
        self._skinEntries[control] = refresh
        local original = control.Set
        if type(original) == "function" then
            control.Set = function(instance, ...)
                local result = table.pack(original(instance, ...))
                if not self._destroyed then refresh(true) end
                return table.unpack(result, 1, result.n)
            end
        end
        refresh(false)
    end)
end

function Hub:SetControlTheme(value)
    if self._destroyed then return false, "hub destroyed" end
    if value ~= "Default" and value ~= "Rounded" then
        return false, "control theme must be Default or Rounded"
    end
    if self:GetControlTheme() == value then return true end
    self._controlTheme = value
    self.Options.ControlTheme = value
    self:_savePref("ControlTheme", value)
    for _, refresh in self._skinEntries or {} do
        local ok, err = pcall(refresh, true)
        if not ok then warn("[RelaxUI] control theme refresh: " .. tostring(err)) end
    end
    if self._controlThemeControl and self._controlThemeControl.Value ~= value then
        self._controlThemeControl:Set(value, true)
    end
    return true
end

function Hub:RefreshControlTheme()
    for _, refresh in self._skinEntries or {} do
        pcall(refresh, false, true)
    end
end

function Hub:GetColorTheme()
    return self.ThemeName
end

function Hub:SetColorTheme(name)
    -- Keep the existing theme API working for third-party hubs.
    return self:SetTheme(name)
end

end
-- SPDX-License-Identifier: MPL-2.0
-- Design Tokens v2. Semantic palette + independent geometry, type, motion and
-- interaction states. No new RenderStepped loops or per-control polling.
do
    local semanticColors = {
        Surface0 = "Panel", Surface1 = "Field", Surface2 = "Tile",
        SurfaceActive = "TileActive",
        BorderSubtle = "PanelStroke", BorderStrong = "TileActiveStroke",
        TextPrimary = "Text", TextSecondary = "SubText", TextMuted = "Muted",
        Accent = "Accent", AccentText = "AccentText",
        Success = "Success", Warning = "Warning", Danger = "Danger",
        Focus = "Accent", Track = "Track", Knob = "Knob",
        DialogSurface = "Panel", DialogBodySurface = "Field",
        DialogIconSurface = "Field", DialogScrim = "Scrim",
        DialogBorder = "PanelStroke", DialogTitle = "Text",
        DialogBodyText = "SubText", DialogDetailText = "Muted",
        DialogIcon = "Text", DialogCloseIcon = "SubText",
        DialogButtonSurface = "Tile", DialogButtonText = "Text",
        DialogButtonBorder = "FieldStroke", DialogPrimarySurface = "Accent",
        DialogPrimaryText = "AccentText", DialogDangerText = "Danger",
        DialogErrorText = "Danger", LockShade = "Scrim", LockIcon = "Text",
        ButtonSurface = "Tile", ButtonHover = "TileHover",
        ButtonText = "Text", ButtonBorder = "TileStroke",
        InputSurface = "Field", InputText = "Text",
        InputBorder = "FieldStroke", PopupSurface = "Panel",
        PopupBorder = "PanelStroke", PopupItemSurface = "Tile",
        PopupItemText = "Text", PopupItemSelected = "TileActive",
    }
    local geometry = {
        Radius = { XS = 6, S = 8, M = 12, L = 16, Pill = 999 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24 },
        Typography = {
            Head = { Size = 15, Weight = "SemiBold", LineHeight = 1.10 },
            Body = { Size = 13, Weight = "Regular", LineHeight = 1.15 },
            Meta = { Size = 11, Weight = "Medium", LineHeight = 1.20 },
            DialogTitle = { Size = 15, Weight = "SemiBold", LineHeight = 1.10 },
            DialogBody = { Size = 12, Weight = "Regular", LineHeight = 1.20 },
            DialogDetail = { Size = 11, Weight = "Regular", LineHeight = 1.20 },
            DialogButton = { Size = 12, Weight = "Medium", LineHeight = 1.10 },
            DialogError = { Size = 11, Weight = "Regular", LineHeight = 1.20 },
            ButtonLabel = { Size = 13, Weight = "Medium", LineHeight = 1.10 },
            ControlLabel = { Size = 13, Weight = "Regular", LineHeight = 1.15 },
            ControlDescription = { Size = 11, Weight = "Regular", LineHeight = 1.20 },
            PopupItem = { Size = 13, Weight = "Regular", LineHeight = 1.15 },
            ModuleTitle = { Size = 16, Weight = "SemiBold", LineHeight = 1.10 },
            ModuleSummary = { Size = 13, Weight = "Regular", LineHeight = 1.20 },
        },
        Components = {
            Dialog = {
                Width = 382, MinWidth = 260, MaxWidth = 460, MaxHeight = 600,
                MinViewportHeight = 210, EdgeInset = 16, Radius = 16,
                PaddingX = 18, PaddingY = 16, Gap = 10,
                HeadingHeight = 34, IconPlateSize = 32, IconPlateRadius = 10,
                IconSize = 18, CloseSize = 36, CloseIconSize = 17,
                TitleGap = 10, TitleTop = 2,
                BodyRadius = 10, BodyPaddingX = 12, BodyPaddingY = 10,
                BodyGap = 10, BodyMinHeight = 36, BodyMaxHeight = 170,
                BodyTransparency = .35, ScrimTransparency = .46,
                ButtonHeight = 36, ButtonGap = 7, ButtonMinWidth = 88,
                ButtonMaxWidth = 148, ButtonRadius = 9, MaxHorizontalButtons = 3,
                LockTransparency = .40, LockRadius = 8,
                LockPlateSize = 36, LockIconSize = 19,
            },
            Button = { Height = 28, RoundedExtraHeight = 2, Radius = 6,
                RoundedRadius = 12, PaddingX = 14, IconSize = 14 },
            Popup = { Width = 190, Radius = 10, EdgeInset = 8,
                Gap = 6, ItemHeight = 28, IconSize = 14 },
            Input = { Height = 26, Radius = 6, ChipHeight = 24,
                ChipRadius = 6 },
            ModuleCard = { SurfaceRadius = 10, HeaderHeight = 92,
                IconSize = 52, GlyphSize = 28, SwitchWidth = 34,
                SwitchHeight = 20, HitTarget = 44, ActionHitTarget = 40 },
        },
        Motion = {
            Mode = "Full",
            Fast = { Duration = .14, Easing = "Quint", Direction = "Out" },
            Control = { Duration = .20, Easing = "Quad", Direction = "Out" },
            Panel = { Duration = .32, Easing = "Quint", Direction = "Out" },
            Dismiss = { Duration = .16, Easing = "Quad", Direction = "In" },
            Ripple = { Duration = .52, Easing = "Quart", Direction = "Out" },
        },
        State = {
            Idle = { Surface = "Surface2", Text = "TextPrimary", Opacity = 1 },
            Hover = { Surface = "SurfaceActive", Text = "TextPrimary", Opacity = 1 },
            Pressed = { Surface = "SurfaceActive", Text = "Accent", Opacity = 1 },
            Focused = { Surface = "Surface1", Text = "Accent", Opacity = 1 },
            Disabled = { Surface = "Surface1", Text = "TextMuted", Opacity = .55 },
            Dragging = { Surface = "SurfaceActive", Text = "Accent", Opacity = 1 },
            Loading = { Surface = "Surface1", Text = "TextSecondary", Opacity = .8 },
            Error = { Surface = "Surface1", Text = "Danger", Opacity = 1 },
        },
    }
    local function deepCopy(value)
        -- Roblox Color3 is a value type; the headless engine represents it as
        -- a readonly table. Both cases must stay atomic, never be recursed.
        if typeof(value) ~= "table" or type(value) ~= "table" then return value end
        local out = {}
        for k, v in value do out[k] = deepCopy(v) end
        return out
    end
    -- Export independent snapshots: callers modifying the public catalog must
    -- never change the schema used by existing or future hubs.
    RiftUI.DesignTokensV2 = {
        Version = 2,
        ColorRoles = deepCopy(semanticColors),
        Radius = deepCopy(geometry.Radius),
        Spacing = deepCopy(geometry.Spacing),
        Typography = deepCopy(geometry.Typography),
        Components = deepCopy(geometry.Components),
        Motion = deepCopy(geometry.Motion),
        State = deepCopy(geometry.State),
    }
    local function defaults(theme, extensions)
        local colors = {}
        for role, legacy in semanticColors do colors[role] = theme[legacy] end
        local result = deepCopy(geometry)
        for name, component in extensions or {} do
            result.Components[name] = deepCopy(component)
        end
        result.Version = 2
        result.Color = colors
        return result
    end
    local function readColor(value)
        if typeof(value) == "Color3" then return value end
        if type(value) == "string" and string.match(value, "^#?%x%x%x%x%x%x$") then
            local ok, color = pcall(Color3.fromHex, value)
            if ok then return color end
        end
        return nil
    end
    local function validate(target, supplied, schema, group)
        if type(supplied) ~= "table" then return false, group .. " must be a table" end
        for key, value in supplied do
            local sample = schema[key]
            if sample == nil then return false, "unknown token: " .. group .. "." .. tostring(key) end
            local path = group .. "." .. tostring(key)
            if group == "Color" or typeof(sample) == "Color3" then
                local color = readColor(value)
                if not color then return false, path .. " must be Color3 or #RRGGBB" end
                target[key] = color
            elseif type(sample) == "table" then
                if type(value) ~= "table" then return false, path .. " must be a table" end
                target[key] = target[key] or {}
                local ok, err = validate(target[key], value, sample, path)
                if not ok then return false, err end
            elseif type(sample) == "number" then
                if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
                    return false, path .. " requires a finite number"
                end
                local lo, hi = 0, 999
                if string.find(path, "Spacing.", 1, true) then hi = 64
                elseif string.find(path, "Typography.", 1, true) then
                    lo, hi = string.find(path, ".LineHeight", 1, true) and .8 or 10,
                        string.find(path, ".LineHeight", 1, true) and 2 or 32
                elseif string.find(path, "Motion.", 1, true) then hi = 3
                elseif string.find(path, "State.", 1, true) then hi = 1
                elseif string.find(path, "Components.", 1, true) then
                    if string.find(path, "Transparency", 1, true) then hi = 1
                    elseif string.find(path, "Radius", 1, true) then hi = 100
                    else hi = 999 end
                end
                if value < lo or value > hi then return false, path .. " outside allowed range" end
                target[key] = value
            elseif type(sample) == "boolean" then
                if type(value) ~= "boolean" then return false, path .. " requires a boolean" end
                target[key] = value
            elseif type(sample) == "string" then
                if type(value) ~= "string" then return false, path .. " requires a string" end
                if key == "Mode" and group == "Motion" then
                    if value ~= "Full" and value ~= "Reduced" and value ~= "Off" then
                        return false, path .. " must be Full, Reduced or Off"
                    end
                elseif key == "Weight" then
                    if value ~= "Regular" and value ~= "Medium" and value ~= "SemiBold" and value ~= "Bold" then
                        return false, path .. " invalid font weight"
                    end
                elseif key == "Easing" then
                    if value ~= "Quint" and value ~= "Quad" and value ~= "Quart" and value ~= "Linear" then
                        return false, path .. " invalid easing"
                    end
                elseif key == "Direction" then
                    if value ~= "In" and value ~= "Out" and value ~= "InOut" then
                        return false, path .. " invalid direction"
                    end
                elseif key == "Surface" or key == "Text" then
                    if semanticColors[value] == nil then
                        return false, path .. " unknown color role"
                    end
                end
                target[key] = value
            else
                return false, path .. " unsupported value type"
            end
        end
        return true
    end
    -- Extension schemas are hub-local and flat so existing token paths,
    -- ResetToken() and the JSON-compatible setup format stay unchanged.
    local function validateComponentExtension(name, fields, registered)
        if type(name) ~= "string" or #name > 48
            or not string.match(name, "^[%a_][%w_]*$") then
            return nil, "component token name must be an identifier (max 48 characters)"
        end
        if geometry.Components[name] or registered[name] then
            return nil, "component token group already exists: " .. name
        end
        if type(fields) ~= "table" or next(fields) == nil then
            return nil, "component token defaults must be a non-empty table"
        end
        local count = 0
        for key, value in fields do
            count += 1
            if count > 64 then return nil, "component token group exceeds 64 fields" end
            if type(key) ~= "string" or #key > 48
                or not string.match(key, "^[%a_][%w_]*$") then
                return nil, "component field name must be an identifier (max 48 characters)"
            end
            if type(value) == "table" and typeof(value) == "table" then
                return nil, "component token fields must be scalar (one nesting level)"
            end
        end
        local normalized = {}
        local ok, err = validate(normalized, fields, fields, "Components." .. name)
        if not ok then return nil, err end
        return normalized
    end

    local function mergeOverrides(previous, patch, palette, extensions)
        if type(patch) ~= "table" then return nil, "token overrides must be a table" end
        if patch.Version ~= nil and patch.Version ~= 2 then
            return nil, "unsupported design token version"
        end
        local nextOverrides = deepCopy(previous)
        local schema = defaults(palette, extensions)
        for group, source in patch do
            if group ~= "Version" then
                if type(schema[group]) ~= "table" then return nil, "unknown token group: " .. tostring(group) end
                nextOverrides[group] = nextOverrides[group] or {}
                local ok, err = validate(nextOverrides[group], source, schema[group], group)
                if not ok then return nil, err end
            end
        end
        return nextOverrides
    end
    local function mergeDeep(target, source)
        for key, value in source do
            if type(value) == "table" and typeof(value) == "table"
                and type(target[key]) == "table" then
                mergeDeep(target[key], value)
            else
                target[key] = deepCopy(value)
            end
        end
    end
    local function createTokens(theme, overrides, extensions)
        local result = defaults(theme, extensions)
        mergeDeep(result, overrides)
        return result
    end
    local function encodeTokenValues(value)
        if typeof(value) == "Color3" then return "#" .. value:ToHex() end
        if type(value) ~= "table" or typeof(value) ~= "table" then return value end
        local out = {}
        for key, nested in value do out[key] = encodeTokenValues(nested) end
        return out
    end
    local function storage(overrides)
        local result = { Version = 2 }
        for group, values in overrides do
            result[group] = encodeTokenValues(values)
        end
        return result
    end
    local function pathValue(tokens, path)
        if type(path) ~= "string" then return nil end
        local current = tokens
        local count = 0
        for key in string.gmatch(path, "[^%.]+") do
            count += 1
            if count > 4 or type(current) ~= "table" then return nil end
            current = current[key]
            if current == nil then return nil end
        end
        return current
    end
    -- Validate canonical leaf and nested override paths before selective reset.
    local function tokenPathParts(path, theme, extensions)
        if type(path) ~= "string" or string.sub(path, 1, 1) == "."
            or string.sub(path, -1) == "." or string.find(path, "..", 1, true) then
            return nil
        end
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        if #parts < 2 or #parts > 3 or pathValue(defaults(theme, extensions), path) == nil then return nil end
        return parts
    end
    local function assignToken(hub, inst, entry)
        if not inst or not inst.Parent then return false end
        local value = pathValue(hub.Tokens, entry.Path)
        if value == nil then return false end
        if entry.Property == "CornerRadius" and type(value) == "number" then
            value = UDim.new(0, value)
        elseif string.find(entry.Property, "Padding", 1, true) and type(value) == "number" then
            value = UDim.new(0, value)
        end
        if entry.Transform then
            local ok, mapped = pcall(entry.Transform, value, hub)
            if not ok then return false end
            value = mapped
        end
        return pcall(function() inst[entry.Property] = value end)
    end

    function Hub:_initDesignTokens(options, saved)
        local extensions = {}
        -- Custom component definitions provided at construction load before
        -- saved overrides, so named configs and persisted values resolve.
        for name, fields in type(options.TokenComponents) == "table"
            and options.TokenComponents or {} do
            local schema, err = validateComponentExtension(name, fields, extensions)
            if schema then extensions[name] = schema
            else warn("[RelaxUI Tokens] custom component ignored: " .. tostring(err)) end
        end
        self._tokenExtensions = extensions
        self._pendingComponentTokenOverrides = {}
        local overrides = {}
        for _, patch in { options.DesignTokens, saved and saved.DesignTokens } do
            if type(patch) == "table" then
                -- Preserve unknown custom component values until a script
                -- registers its schema after CreateHub. Built-ins keep strict
                -- validation; unknown top-level groups remain invalid.
                local recognized = deepCopy(patch)
                if type(recognized.Components) == "table" then
                    for name, values in recognized.Components do
                        if not geometry.Components[name] and not extensions[name] then
                            self._pendingComponentTokenOverrides[name] = deepCopy(values)
                            recognized.Components[name] = nil
                        end
                    end
                    if next(recognized.Components) == nil then recognized.Components = nil end
                end
                local nextValue = mergeOverrides(overrides, recognized, self.Theme, extensions)
                if nextValue then overrides = nextValue end
            end
        end
        self._designTokenOverrides = overrides
        self._tokenBindings = setmetatable({}, { __mode = "k" })
        self._tokenStateBindings = setmetatable({}, { __mode = "k" })
        self._designTokenListeners = {}
        self.Tokens = createTokens(self.Theme, overrides, extensions)
        self._motionMode = self.Tokens.Motion.Mode
    end

    function Hub:GetDesignTokens() return deepCopy(self.Tokens) end
    function Hub:GetDesignTokenOverrides()
        local result = storage(self._designTokenOverrides or {})
        for name, values in self._pendingComponentTokenOverrides or {} do
            result.Components = result.Components or {}
            result.Components[name] = deepCopy(values)
        end
        return result
    end
    function Hub:GetToken(path)
        return deepCopy(pathValue(self.Tokens, path))
    end
    Hub.ResolveToken = Hub.GetToken
    function Hub:GetRegisteredComponentTokens()
        return deepCopy(self._tokenExtensions or {})
    end
    function Hub:RegisterComponentTokens(name, fields)
        if self._destroyed then return false, "hub destroyed" end
        local extensions = self._tokenExtensions or {}
        local normalized, err = validateComponentExtension(name, fields, extensions)
        if not normalized then return false, err end
        local overrides = deepCopy(self._designTokenOverrides or {})
        local pending = self._pendingComponentTokenOverrides
            and self._pendingComponentTokenOverrides[name]
        if pending ~= nil then
            local nextValues = {}
            local ok, reason = validate(nextValues, pending, normalized,
                "Components." .. name)
            if ok then
                overrides.Components = overrides.Components or {}
                overrides.Components[name] = nextValues
            else
                -- An invalid saved value is not allowed to block the component
                -- itself; discard it instead of poisoning the token schema.
                warn("[RelaxUI Tokens] invalid saved component overrides: " .. tostring(reason))
            end
        end
        extensions[name] = normalized
        self._tokenExtensions = extensions
        self._designTokenOverrides = overrides
        if self._pendingComponentTokenOverrides then
            self._pendingComponentTokenOverrides[name] = nil
        end
        -- Keep the registration across Reinitialize() without storing schema
        -- metadata in user configs; other hubs still have isolated catalogs.
        -- Do not mutate a caller-owned options table shared by other hubs.
        self.Options = table.clone(self.Options)
        self.Options.TokenComponents = deepCopy(self.Options.TokenComponents or {})
        self.Options.TokenComponents[name] = deepCopy(normalized)
        self:_refreshDesignTokens()
        return true
    end
    function Hub:GetComponentTokens(name)
        if type(name) ~= "string" then return nil end
        return deepCopy(self.Tokens and self.Tokens.Components[name])
    end
    function Hub:WatchDesignTokens(callback)
        if self._destroyed then return nil, "hub destroyed" end
        if type(callback) ~= "function" then return nil, "callback must be a function" end
        local handle = { Connected = true }
        local hub = self
        self._designTokenListeners[handle] = callback
        function handle:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            if hub._designTokenListeners then hub._designTokenListeners[self] = nil end
        end
        return handle
    end
    -- Subscribe to a single leaf or subtree, rather than triggering custom
    -- components for unrelated theme / geometry updates.
    local function equalTokenValues(a, b)
        if typeof(a) ~= "table" or typeof(b) ~= "table"
            or type(a) ~= "table" or type(b) ~= "table" then
            return a == b
        end
        for key, value in a do
            if not equalTokenValues(value, b[key]) then return false end
        end
        for key in b do
            if a[key] == nil then return false end
        end
        return true
    end
    function Hub:WatchToken(path, callback, immediate)
        if self._destroyed then return nil, "hub destroyed" end
        if type(path) ~= "string" or type(callback) ~= "function" then
            return nil, "token path and callback required"
        end
        local previous = self:GetToken(path)
        if previous == nil then return nil, "unknown token path" end
        local handle = self:WatchDesignTokens(function(tokens)
            local value = pathValue(tokens, path)
            if value == nil or equalTokenValues(previous, value) then return end
            previous = deepCopy(value)
            callback(deepCopy(previous), path)
        end)
        if immediate then
            local ok, err = pcall(callback, deepCopy(previous), path)
            if not ok then warn("[RelaxUI Tokens] WatchToken: " .. tostring(err)) end
        end
        return handle
    end
    function Hub:BindComponentTokens(inst, properties)
        if type(properties) ~= "table" then return nil, "properties must be a table" end
        local handles = {}
        for property, path in properties do
            local binding, err = self:BindToken(inst, property, path)
            if not binding then
                for _, prior in handles do prior:Disconnect() end
                return nil, err
            end
            table.insert(handles, binding)
        end
        local composite = { Connected = true }
        function composite:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            for _, binding in handles do binding:Disconnect() end
        end
        return composite
    end

    function Hub:_refreshDesignTokens()
        self.Tokens = createTokens(self.Theme, self._designTokenOverrides or {},
            self._tokenExtensions)
        self._motionMode = self.Tokens.Motion.Mode
        if self.Gui then self.Gui:SetAttribute("RelaxMotionMode", self._motionMode) end
        if self.RefreshControlTheme then self:RefreshControlTheme() end
        for inst, entries in self._tokenBindings or {} do
            if inst.Parent then
                for _, entry in entries do assignToken(self, inst, entry) end
            else
                for _, entry in entries do
                    if entry.Handle then entry.Handle.Connected = false end
                end
                self._tokenBindings[inst] = nil
            end
        end
        -- Stateful styling takes priority over ordinary property bindings.
        for inst, binding in self._tokenStateBindings or {} do
            if binding.Connected and inst.Parent then
                self:ApplyTokenState(inst, binding.State)
            else
                binding:Disconnect()
            end
        end
        -- Components with coupled geometry (responsive dialogs, popup lists)
        -- subscribe once. No per-control RenderStepped or background polling.
        for handle, callback in self._designTokenListeners or {} do
            if handle.Connected then
                local ok, err = pcall(callback, self.Tokens)
                if not ok then warn("[RelaxUI Tokens] refresh: " .. tostring(err)) end
            end
        end
    end

    function Hub:SetDesignTokens(patch, persist)
        if self._destroyed then return false, "hub destroyed" end
        local updated, err = mergeOverrides(self._designTokenOverrides or {}, patch,
            self.Theme, self._tokenExtensions)
        if not updated then return false, err end
        self._designTokenOverrides = updated
        self:_refreshDesignTokens()
        if persist ~= false then self:_savePref("DesignTokens", self:GetDesignTokenOverrides()) end
        return true
    end
    function Hub:ResetDesignTokens(persist)
        if self._destroyed then return false, "hub destroyed" end
        self._designTokenOverrides = {}
        self._pendingComponentTokenOverrides = {}
        self:_refreshDesignTokens()
        if persist ~= false then self:_savePref("DesignTokens", { Version = 2 }) end
        return true
    end
    function Hub:SetToken(path, value, persist)
        if type(path) ~= "string" then return false, "invalid token path" end
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        if #parts < 2 or #parts > 3 then return false, "invalid token path" end
        local patch = {}
        local node = patch
        for i, part in parts do
            if i == #parts then node[part] = value
            else node[part] = {}; node = node[part] end
        end
        return self:SetDesignTokens(patch, persist)
    end
    -- Inspect and remove individual overrides without resetting the palette
    -- or other token values. Full nested roles may also be reset.
    function Hub:GetTokenOverride(path)
        local parts = tokenPathParts(path, self.Theme, self._tokenExtensions)
        if not parts then return nil end
        local node = self._designTokenOverrides or {}
        for _, key in parts do
            if type(node) ~= "table" then return nil end
            node = node[key]
            if node == nil then return nil end
        end
        return deepCopy(node)
    end
    function Hub:HasTokenOverride(path)
        return self:GetTokenOverride(path) ~= nil
    end
    function Hub:ResetToken(path, persist)
        if self._destroyed then return false, "hub destroyed" end
        local parts = tokenPathParts(path, self.Theme, self._tokenExtensions)
        if not parts then return false, "invalid token path" end
        local overrides = deepCopy(self._designTokenOverrides or {})
        local node, ancestors = overrides, {}
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(node[key]) ~= "table" then return true end
            table.insert(ancestors, { Node = node, Key = key })
            node = node[key]
        end
        if node[parts[#parts]] == nil then return true end
        node[parts[#parts]] = nil
        for i = #ancestors, 1, -1 do
            local entry = ancestors[i]
            if next(entry.Node[entry.Key]) ~= nil then break end
            entry.Node[entry.Key] = nil
        end
        self._designTokenOverrides = overrides
        self:_refreshDesignTokens()
        if persist ~= false then self:_savePref("DesignTokens", self:GetDesignTokenOverrides()) end
        return true
    end
    function Hub:GetMotionMode() return self._motionMode end
    function Hub:SetMotionMode(mode, persist)
        return self:SetDesignTokens({ Motion = { Mode = mode } }, persist)
    end
    function Hub:TokenTween(inst, preset, goals)
        local data = self:GetToken("Motion." .. tostring(preset or "Control"))
        if type(data) ~= "table" or type(data.Duration) ~= "number" then
            return nil, "unknown motion preset"
        end
        local easing = Enum.EasingStyle[data.Easing]
        local direction = Enum.EasingDirection[data.Direction]
        if self._motionMode == "Off" then
            cancelMotion(inst)
            for property, value in goals do setThemed(inst, property, value) end
            return nil
        end
        local duration = self._motionMode == "Reduced" and math.min(data.Duration, .06)
            or data.Duration
        return tween(inst, TweenInfo.new(duration, easing, direction), goals)
    end
    function Hub:BindToken(inst, property, path, transform)
        if self._destroyed then return nil, "hub destroyed" end
        if not inst or not inst:IsDescendantOf(self.Gui)
            or type(property) ~= "string" or type(path) ~= "string"
            or pathValue(self.Tokens, path) == nil then
            return nil, "invalid token binding"
        end
        if transform ~= nil and type(transform) ~= "function" then
            return nil, "transform must be a function"
        end
        local entries = self._tokenBindings[inst] or {}
        local entry = { Property = property, Path = path, Transform = transform }
        if not assignToken(self, inst, entry) then return nil, "token cannot be assigned to property" end
        -- Exactly one owner per instance/property: invalidate superseded handles.
        for i = #entries, 1, -1 do
            local previous = entries[i]
            if previous.Property == property then
                if previous.Handle then previous.Handle.Connected = false end
                table.remove(entries, i)
            end
        end
        self._tokenBindings[inst] = entries
        table.insert(entries, entry)
        local binding = { Connected = true }
        entry.Handle = binding
        local hub = self
        function binding:Disconnect()
            if not binding.Connected then return end
            binding.Connected = false
            local at = table.find(entries, entry)
            if at then table.remove(entries, at) end
            if #entries == 0 and hub._tokenBindings then hub._tokenBindings[inst] = nil end
        end
        return binding
    end
    function Hub:ApplyTokenState(inst, state)
        local spec = self.Tokens.State[state]
        if not inst or not spec then return false, "unknown control state" end
        local colors = self.Tokens.Color
        local ok = pcall(function()
            inst.BackgroundColor3 = colors[spec.Surface]
            inst.BackgroundTransparency = 1 - spec.Opacity
            if inst:IsA("TextButton") or inst:IsA("TextLabel") then
                inst.TextColor3 = colors[spec.Text]
            end
        end)
        return ok
    end

    -- Opt-in live semantic states; no input listeners and no per-frame work.
    function Hub:BindTokenState(inst, state)
        if self._destroyed then return nil, "hub destroyed" end
        if not inst or not inst:IsDescendantOf(self.Gui) then
            return nil, "state target must belong to this hub"
        end
        if type(state) ~= "string" or not self.Tokens.State[state] then
            return nil, "unknown control state"
        end
        local existing = self._tokenStateBindings[inst]
        if existing and existing.Connected then
            local ok, err = existing:SetState(state)
            if not ok then return nil, err end
            return existing
        end
        local hub = self
        local handle = { Connected = true, State = state }
        function handle:GetState() return self.State end
        function handle:SetState(nextState)
            if not self.Connected or hub._destroyed or not inst.Parent then
                return false, "state binding disconnected"
            end
            if type(nextState) ~= "string" or not hub.Tokens.State[nextState] then
                return false, "unknown control state"
            end
            local ok, err = hub:ApplyTokenState(inst, nextState)
            if not ok then return false, err end
            self.State = nextState
            return true
        end
        function handle:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            if hub._tokenStateBindings and hub._tokenStateBindings[inst] == self then
                hub._tokenStateBindings[inst] = nil
            end
        end
        local ok, err = handle:SetState(state)
        if not ok then return nil, err end
        self._tokenStateBindings[inst] = handle
        return handle
    end

    -- GUI teardown invalidates retained handles before destroying Instances.
    function Hub:_disposeDesignTokens()
        for _, entries in self._tokenBindings or {} do
            for _, entry in entries do
                if entry.Handle then entry.Handle.Connected = false end
            end
        end
        for _, binding in self._tokenStateBindings or {} do binding.Connected = false end
        self._tokenBindings = nil
        self._tokenStateBindings = nil
        self._pendingComponentTokenOverrides = nil
        self._tokenExtensions = nil
        for handle in self._designTokenListeners or {} do handle.Connected = false end
        self._designTokenListeners = nil
    end

    function Hub:_bindDesignTokenShell()
        self.Gui:SetAttribute("RelaxMotionMode", self._motionMode)
        if self.Dock then
            self:BindToken(self.Dock, "BackgroundColor3", "Color.Surface0")
            self:BindToken(self.Dock:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.M")
        end
        if self.Panel then
            self:BindToken(self.Panel, "BackgroundColor3", "Color.Surface0")
            self:BindToken(self.Panel:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.L")
        end
        if self.PanelOutlineStroke then
            self:BindToken(self.PanelOutlineStroke, "Color", "Color.BorderSubtle")
        end
        if self.HeaderTitle then
            self:BindToken(self.HeaderTitle, "TextSize", "Typography.Head.Size")
        end
        if self.HeaderSub then
            self:BindToken(self.HeaderSub, "TextSize", "Typography.Meta.Size")
        end
        if self.Search then
            self:BindToken(self.Search, "TextSize", "Typography.Body.Size")
        end
        if self.Tooltip then
            self:BindToken(self.Tooltip:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
        end
    end
end


do
-- SPDX-License-Identifier: MPL-2.0
-- Lightweight hub resource ownership, inspired by OasisUI's Maid and MacUI's Cleanup.
local function disposeRiftResource(resource)
    if type(resource) == "function" then
        resource()
    elseif typeof(resource) == "RBXScriptConnection" then
        resource:Disconnect()
    elseif typeof(resource) == "Instance" then
        resource:Destroy()
    elseif type(resource) == "table" then
        if type(resource.Disconnect) == "function" then resource:Disconnect()
        elseif type(resource.Destroy) == "function" then resource:Destroy()
        elseif type(resource.Cancel) == "function" then resource:Cancel()
        end
    end
end

function Hub:Own(resource)
    if self._destroyed then
        pcall(disposeRiftResource, resource)
        return resource
    end
    self._owned = self._owned or {}
    table.insert(self._owned, resource)
    return resource
end

function Hub:_releaseOwned()
    local owned = self._owned or {}
    self._owned = nil
    for i = #owned, 1, -1 do
        local ok, err = pcall(disposeRiftResource, owned[i])
        if not ok then warn("[RiftUI] resource cleanup: " .. tostring(err)) end
        owned[i] = nil
    end
end

end

do
-- SPDX-License-Identifier: MPL-2.0
-- RiftUI UI sounds. Inspired by VantaUI's Soft/Minimal event maps (MIT).
-- Original synthesized WAVs: MrRos3/VantaUI, see assets/sounds/LICENSE-VantaUI.txt.
-- Lazy, cached, rate-limited and safe on executors without custom sound assets.
local SOUND_BASE = "https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/assets/sounds/"
local SOUND_FALLBACK = "rbxasset://sounds/electronicpingshort.wav"
local SOUND_FILES = {
    ["soft-pop"] = "soft-pop.wav", ["soft-tick"] = "soft-tick.wav",
    ["minimal-tick"] = "minimal-tick.wav", ["minimal-confirm"] = "minimal-confirm.wav",
    ["error-buzz"] = "error-buzz.wav",
}
local SOUND_PRESETS = {
    Soft = {
        Click = {"soft-tick", .36, 1}, Tab = {"soft-pop", .43, 1.07},
        ToggleOn = {"soft-pop", .44, 1.1}, ToggleOff = {"soft-tick", .3, .9},
        DropdownOpen = {"soft-pop", .35, 1.12}, DropdownClose = {"soft-tick", .3, .9},
        Select = {"soft-tick", .33, 1.06}, SliderTick = {"soft-tick", .14, 1.22},
        InputFocus = {"soft-tick", .22, 1.1}, InputSubmit = {"soft-pop", .35, 1},
        WindowOpen = {"soft-pop", .45, .92}, WindowClose = {"soft-tick", .32, .82},
        Success = {"soft-pop", .48, 1.1}, Error = {"error-buzz", .35, 1},
    },
    Minimal = {
        Click = {"minimal-tick", .36, 1}, Tab = {"minimal-confirm", .43, 1.07},
        ToggleOn = {"minimal-confirm", .44, 1.1}, ToggleOff = {"minimal-tick", .3, .9},
        DropdownOpen = {"minimal-confirm", .35, 1.12}, DropdownClose = {"minimal-tick", .3, .9},
        Select = {"minimal-tick", .33, 1.06}, SliderTick = {"minimal-tick", .14, 1.22},
        InputFocus = {"minimal-tick", .22, 1.1}, InputSubmit = {"minimal-confirm", .35, 1},
        WindowOpen = {"minimal-confirm", .45, .92}, WindowClose = {"minimal-tick", .32, .82},
        Success = {"minimal-confirm", .48, 1.1}, Error = {"error-buzz", .35, 1},
    },
}
local SOUND_LIMIT = { SliderTick = .09, Click = .05, Tab = .06, DropdownOpen = .08, Select = .05 }
local soundCache, soundLoading = {}, {}
local soundWarnings = {}

local function soundWarnOnce(key, err)
    if soundWarnings[key] then return end
    soundWarnings[key] = true
    warn("[RiftUI Sounds] " .. tostring(err))
end

local function soundEnsureFolder(path)
    if type(makefolder) ~= "function" then return end
    local cursor = ""
    for part in string.gmatch(path, "[^/]+") do
        cursor = cursor == "" and part or cursor .. "/" .. part
        if type(isfolder) ~= "function" or not isfolder(cursor) then
            pcall(makefolder, cursor)
        end
    end
end

local function soundResolveAsset(soundName: string, hub)
    local config = hub._soundConfig
    local source = (config.Assets and config.Assets[soundName]) or SOUND_FILES[soundName] or soundName
    if type(source) ~= "string" then return SOUND_FALLBACK end
    if source:match("^rbxasset") or source:match("^synasset") then return source end
    if hub.Stealth or type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
        return SOUND_FALLBACK
    end
    local url = source:match("^https?://") and source or (SOUND_BASE .. source)
    local key = (url:gsub("[^%w]", "_")):sub(-70)
    if soundCache[key] then return soundCache[key] end
    if soundLoading[key] then return SOUND_FALLBACK end
    soundLoading[key] = true
    local ok, result = pcall(function()
        local dir = RiftUI.Folder .. "/sounds"
        local path = dir .. "/" .. key .. ".wav"
        soundEnsureFolder(dir)
        if type(isfile) ~= "function" or not isfile(path) then
            local body = nil
            local req = (syn and syn.request) or http_request or request
            if req then
                local response = req({Url = url, Method = "GET"})
                body = response and (response.Body or response.body)
            else
                body = game:HttpGet(url)
            end
            if type(body) ~= "string" or #body < 44 or body:sub(1, 4) ~= "RIFF" or body:sub(9, 12) ~= "WAVE" then
                error("invalid WAV data for " .. soundName)
            end
            writefile(path, body)
        end
        return getcustomasset(path)
    end)
    soundLoading[key] = nil
    if not ok or type(result) ~= "string" or result == "" then
        soundWarnOnce(key, result)
        result = SOUND_FALLBACK
    end
    soundCache[key] = result
    return result
end

function Hub:GetUISounds()
    return table.clone(self._soundConfig or { Enabled = true, Preset = "Soft", Volume = .65 })
end

function Hub:SetUISounds(options)
    local current = self._soundConfig or { Enabled = true, Preset = "Soft", Volume = .65, Pitch = 1, Assets = {} }
    if type(options) == "boolean" then
        current.Enabled = options
    elseif type(options) == "table" then
        if options.Enabled ~= nil then current.Enabled = options.Enabled == true end
        if options.Preset == "Soft" or options.Preset == "Minimal" then current.Preset = options.Preset end
        if options.Volume ~= nil then current.Volume = math.clamp(tonumber(options.Volume) or current.Volume, 0, 2) end
        if options.Pitch ~= nil then current.Pitch = math.clamp(tonumber(options.Pitch) or current.Pitch, .5, 2) end
        if type(options.Assets) == "table" then
            current.Assets = table.clone(options.Assets)
        end
    end
    self._soundConfig = current
    return self:GetUISounds()
end

function Hub:PlayUISound(eventName: string, options)
    if self._destroyed then return false end
    local cfg = self._soundConfig
    if not cfg or not cfg.Enabled then return false end
    local entry = (SOUND_PRESETS[cfg.Preset] or SOUND_PRESETS.Soft)[eventName]
    if not entry then return false end
    local now = os.clock()
    self._soundLast = self._soundLast or {}
    local limit = SOUND_LIMIT[eventName] or .035
    if now - (self._soundLast[eventName] or -100) < limit then return false end
    self._soundLast[eventName] = now
    task.spawn(function()
        local soundId = soundResolveAsset(entry[1], self)
        if self._destroyed or not self._soundConfig or not self._soundConfig.Enabled then return end
        local ok, sound = pcall(Instance.new, "Sound")
        if not ok or not sound then return end
        local opts = type(options) == "table" and options or {}
        local played, reason = pcall(function()
            sound.Name = "RiftUI_" .. eventName
            sound.SoundId = soundId
            sound.Volume = math.clamp((tonumber(opts.Volume) or entry[2]) * cfg.Volume, 0, 2)
            sound.PlaybackSpeed = math.clamp((tonumber(opts.Pitch) or entry[3]) * cfg.Pitch, .25, 4)
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 5)
        end)
        if not played then sound:Destroy(); soundWarnOnce(eventName, reason) end
    end)
    return true
end

end

-- SPDX-License-Identifier: MPL-2.0
-- Background presets inspired by FlowUI and Aster UI.
-- Works without a custom-asset filesystem; existing file/URL backgrounds remain supported.
RiftUI.BackgroundPresets = {
    ["Deep Violet"] = "rbxassetid://136310484943077",
    ["Blood Red"] = "rbxassetid://121343473918667",
    ["Cyanic"] = "rbxassetid://95656189244173",
    ["Amber Glow"] = "rbxassetid://107795771598485",
    ["Bloomings"] = "rbxassetid://133541508207801",
    ["Lavender Pink"] = "rbxassetid://126107479485287",
}
RiftUI.BackgroundPresetOrder = {
    "Deep Violet", "Blood Red", "Cyanic", "Amber Glow", "Bloomings", "Lavender Pink",
}

local function resolveBackgroundPreset(value)
    if type(value) == "number" then
        return "rbxassetid://" .. tostring(math.floor(value)), nil
    end
    if type(value) ~= "string" then return nil, nil end
    local source = value:match("^%s*(.-)%s*$")
    local preset = RiftUI.BackgroundPresets[source]
    if preset then return preset, source end
    if source:match("^%d+$") then return "rbxassetid://" .. source, nil end
    if source:match("^rbxassetid://%d+$") or source:match("^rbxasset://") or source:match("^rbxthumb://") then
        return source, nil
    end
    return nil, nil
end

function RiftUI:ListBackgroundPresets()
    return table.clone(self.BackgroundPresetOrder)
end

function Hub:ListBackgrounds()
    local values = {"None"}
    for _, name in RiftUI.BackgroundPresetOrder do table.insert(values, name) end
    return values
end

function Hub:GetBackground()
    return self.Background and table.clone(self.Background) or nil
end

function Hub:SetBackgroundPreset(name)
    if name == "None" or name == nil then return self:SetBackground(nil) end
    if not RiftUI.BackgroundPresets[name] then return false, "unknown background preset" end
    return self:SetBackground(name)
end

function Hub:SetBackgroundTransparency(value)
    if self._destroyed then return false end
    local transparency = math.clamp(tonumber(value) or .4, 0, 1)
    self._backgroundTransparency = transparency
    if self.Background then self.Background.Opacity = 1 - transparency end
    for _, layer in self._bgLayers or {} do
        local image = layer:FindFirstChild("Image", true)
        if image then tween(image, FAST, { ImageTransparency = transparency }) end
    end
    local studio = self.SetupData and self.SetupData.Studio
    self:_saveStudio(studio and studio.Colors or {})
    return true
end


do
-- SPDX-License-Identifier: MPL-2.0
-- Extended background-source switching, based on the source types and fading
-- semantics of AsterUI and FlowUI. This is separate from the six UI backgrounds.
local BACKGROUND_TRANSITIONS = { Crossfade = true, Fade = true, Instant = true }

function Hub:GetBackgroundTransition()
    local selected = self._bgTransition
        or (self.SetupData and self.SetupData.BackgroundTransition)
        or (self.Options and self.Options.BackgroundTransition)
        or "Crossfade"
    return BACKGROUND_TRANSITIONS[selected] and selected or "Crossfade"
end

function Hub:SetBackgroundTransition(mode: string)
    if self._destroyed then return false, "hub destroyed" end
    if not BACKGROUND_TRANSITIONS[mode] then
        return false, "transition must be Crossfade, Fade or Instant"
    end
    self._bgTransition = mode
    self:_savePref("BackgroundTransition", mode)
    return true
end

-- Accepts the same kinds of image sources as AsterUI/FlowUI:
-- preset name, asset ID, HTTPS/HTTP image URL, or local executor image path.
-- SetBackground({Url=..., File=..., Asset=...}) continues to work unchanged.
function Hub:SwitchBackground(source)
    if self._destroyed then return false, "hub destroyed" end
    if source == nil or source == false then return self:SetBackground(nil) end
    if type(source) == "table" or type(source) == "number" then
        return self:SetBackground(source)
    end
    if type(source) ~= "string" then return false, "invalid image source" end
    local value = source:match("^%s*(.-)%s*$")
    if value == "" or value == "None" then return self:SetBackground(nil) end
    if RiftUI.BackgroundPresets[value] then return self:SetBackgroundPreset(value) end
    if resolveBackgroundPreset(value) then return self:SetBackground(value) end
    if value:match("^https?://") then
        return self:SetBackground({ Url = value, CacheUnique = true })
    end
    if type(isfile) == "function" and isfile(value) then
        return self:SetBackground({ File = value })
    end
    return false, "use a preset, asset ID, direct image URL or existing image file"
end

end

do
-- SPDX-License-Identifier: MPL-2.0
-- Weather backdrops modeled on the Rain/Snow/Ember/Sakura/Fireflies/Matrix
-- particle systems in AsterUI and FlowUI. Uses Roblox GUI, no executor assets.
-- Particle rendering lives BEHIND the RelaxUI screen (or under its Panel);
-- it never captures clicks or changes text-container layout.
local WEATHER_DEFS = {
    Rain = { Count = 70 },
    Snow = { Count = 55 },
    Ember = { Count = 42 },
    Sakura = { Count = 38 },
    Fireflies = { Count = 28 },
    Matrix = { Count = 30 },
}
local WEATHER_ORDER = { "None", "Rain", "Snow", "Ember", "Sakura", "Fireflies", "Matrix" }
local WEATHER_ALIASES = {
    none = "None", off = "None", rain = "Rain", snow = "Snow",
    ember = "Ember", embers = "Ember", fire = "Ember",
    sakura = "Sakura", petals = "Sakura", fireflies = "Fireflies",
    firefly = "Fireflies", matrix = "Matrix", code = "Matrix",
}
local WX_GLYPHS = "0123456789ABCDEF+-*<>"
local WX_RANDOM = Random.new()
local function wxRoll(min, max) return WX_RANDOM:NextNumber(min, max) end
local function wxName(raw)
    if type(raw) ~= "string" then return nil end
    return WEATHER_ALIASES[raw:lower():gsub("[%s_%-]", "")]
end

function Hub:ListWeather()
    return table.clone(WEATHER_ORDER)
end

function Hub:GetWeather()
    local value = self._weatherKind
        or (self.SetupData and self.SetupData.Weather)
        or (self.Options and self.Options.Weather)
        or "None"
    return wxName(value) or "None"
end

function Hub:GetWeatherMode()
    local mode = self._weatherMode
        or (self.SetupData and self.SetupData.WeatherMode)
        or (self.Options and self.Options.WeatherMode)
    return mode == "UI" and "UI" or "Screen"
end

function Hub:GetWeatherDensity()
    return math.clamp(tonumber(self._weatherDensity
        or (self.SetupData and self.SetupData.WeatherDensity)
        or (self.Options and self.Options.WeatherDensity)) or 1, 0, 2)
end

function Hub:GetWeatherSpeed()
    return math.clamp(tonumber(self._weatherSpeed
        or (self.SetupData and self.SetupData.WeatherSpeed)
        or (self.Options and self.Options.WeatherSpeed)) or 1, 0.25, 2.5)
end

function Hub:_weatherSize()
    if self:GetWeatherMode() == "UI" then
        local size = self.Panel.AbsoluteSize / math.max(self._scale, .01)
        return Vector2.new(math.max(size.X, 300), math.max(size.Y, 120))
    end
    local size = viewport()
    return Vector2.new(math.max(size.X, 320), math.max(size.Y, 200))
end

function Hub:_clearWeatherParticles()
    for _, particle in self._weatherParticles or {} do
        if particle.Gui then particle.Gui:Destroy() end
    end
    self._weatherParticles = {}
end

function Hub:_seedWeatherParticle(kind, particle, anywhere)
    local size = self:_weatherSize()
    local width, height = size.X, size.Y
    local p = particle
    p.Clock = wxRoll(0, 10)
    p.Phase = wxRoll(0, math.pi * 2)
    p.Freq = wxRoll(.5, 1.5)
    p.Life = nil
    p.Age = 0
    p.Sway = 0
    p.Twirl = 0
    p.Alpha = wxRoll(.05, .3)
    if kind == "Rain" then
        p.Width, p.Height = wxRoll(2, 3.5), wxRoll(25, 52)
        p.VY = wxRoll(940, 1340)
        p.VX = p.VY * .10
        p.Rot = -math.deg(math.atan2(p.VX, p.VY))
        p.Alpha = wxRoll(.12, .42)
        p.Gui.BackgroundColor3 = Color3.fromRGB(173, 213, 255)
    elseif kind == "Snow" then
        local d = wxRoll(6, 16)
        p.Width, p.Height = d, d
        p.VY = wxRoll(30, 55) * (.6 + d / 17)
        p.VX = wxRoll(-9, 14)
        p.Sway = wxRoll(12, 34)
        p.Rot = wxRoll(0, 360)
        p.Twirl = wxRoll(-50, 50)
        p.Alpha = wxRoll(.03, .28)
        p.Gui.BackgroundColor3 = Color3.fromRGB(238, 247, 255)
    elseif kind == "Ember" then
        local d = wxRoll(4, 10)
        p.Width, p.Height = d, d
        p.VY, p.VX = -wxRoll(55, 155), wxRoll(-12, 12)
        p.Sway = wxRoll(8, 25)
        p.Twirl = wxRoll(-120, 120)
        p.Rot = wxRoll(0, 360)
        p.Alpha = wxRoll(.08, .40)
        p.Gui.BackgroundColor3 = Color3.fromRGB(255, math.floor(wxRoll(90, 190)), 55)
    elseif kind == "Sakura" then
        local d = wxRoll(7, 14)
        p.Width, p.Height = d, d * wxRoll(.55, .8)
        p.VY, p.VX = wxRoll(35, 70), wxRoll(18, 42)
        p.Sway, p.Twirl = wxRoll(13, 32), wxRoll(-95, 95)
        p.Rot = wxRoll(0, 360)
        p.Gui.BackgroundColor3 = Color3.fromRGB(255, math.floor(wxRoll(145, 205)), math.floor(wxRoll(175, 220)))
    elseif kind == "Fireflies" then
        local d = wxRoll(10, 23)
        p.Width, p.Height = d, d
        p.VY, p.VX = wxRoll(-12, 8), wxRoll(-12, 12)
        p.Sway = wxRoll(12, 25)
        p.Life = wxRoll(5, 11)
        p.Age = anywhere and wxRoll(0, p.Life) or 0
        p.Alpha = wxRoll(.2, .52)
        p.Gui.BackgroundColor3 = Color3.fromRGB(math.floor(wxRoll(200, 245)), 255, math.floor(wxRoll(105, 165)))
    else -- Matrix, code rain
        local n = math.floor(wxRoll(8, 15))
        p.Width, p.Height = 14, n * 14
        p.VY, p.VX = wxRoll(140, 280), 0
        p.Alpha = wxRoll(.2, .52)
        local chars = {}
        for i = 1, n do
            local j = math.floor(wxRoll(1, #WX_GLYPHS + .999))
            chars[i] = WX_GLYPHS:sub(j, j)
        end
        p.Gui.Text = table.concat(chars, "\n")
    end
    p.X = wxRoll(-math.min(width * .12, 85), width)
    if kind == "Ember" then
        p.Y = anywhere and wxRoll(0, height) or height + wxRoll(10, 80)
    elseif kind == "Fireflies" then
        p.Y = wxRoll(height * .2, height)
    else
        p.Y = anywhere and wxRoll(-p.Height, height) or -p.Height - wxRoll(0, 60)
    end
    p.Gui.Size = UDim2.fromOffset(p.Width, p.Height)
    if kind == "Rain" then p.Gui.Rotation = p.Rot end
end

function Hub:_rebuildWeather()
    if not self._weatherField then return end
    self:_clearWeatherParticles()
    self._weatherFrameClock = 0
    local kind = self:GetWeather()
    local def = WEATHER_DEFS[kind]
    if not def or self:GetWeatherDensity() == 0 then
        self._weatherField.Visible = false
        return
    end
    local touch = UserInputService.TouchEnabled
    local maxParticles = touch and 50 or 100
    local count = math.min(maxParticles, math.floor(def.Count * self:GetWeatherDensity()
        * (self:GetWeatherMode() == "UI" and .45 or 1) + .5))
    for _ = 1, count do
        local gui
        if kind == "Matrix" then
            gui = create("TextLabel", {
                Name = "WeatherMatrix", BackgroundTransparency = 1,
                Text = "", TextColor3 = Color3.fromRGB(80, 230, 130),
                TextSize = 12, FontFace = Font.fromEnum(Enum.Font.Code),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = 1, Parent = self._weatherField,
            })
        else
            -- Native GUI particles never depend on unavailable image assets.
            local tint = kind == "Rain" and Color3.fromRGB(173, 213, 255)
                or kind == "Snow" and Color3.fromRGB(238, 247, 255)
                or kind == "Ember" and Color3.fromRGB(255, 160, 73)
                or kind == "Sakura" and Color3.fromRGB(255, 178, 207)
                or Color3.fromRGB(225, 255, 140)
            gui = create("Frame", {
                Name = "Weather" .. kind, BackgroundColor3 = tint,
                BackgroundTransparency = 1, BorderSizePixel = 0, Active = false,
                ZIndex = 1, Parent = self._weatherField,
            }, { corner(kind == "Rain" and 2 or kind == "Sakura" and 5 or 100) })
            if kind == "Rain" then
                create("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, .72),
                        NumberSequenceKeypoint.new(.32, 0),
                        NumberSequenceKeypoint.new(1, .42),
                    }),
                    Parent = gui,
                })
            end
        end
        local particle = { Gui = gui }
        self:_seedWeatherParticle(kind, particle, true)
        table.insert(self._weatherParticles, particle)
    end
end

function Hub:_ensureWeather()
    if self._weatherField then return end
    local screen = create("ScreenGui", {
        Name = "RelaxUIWeather", ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = math.max(0, self.Gui.DisplayOrder - 1),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = self.Gui.Parent,
    })
    local field = create("Frame", {
        Name = "WeatherField", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true, Visible = false,
        ZIndex = 0, Parent = screen,
    })
    self._weatherScreen, self._weatherField = screen, field
    if self:GetWeatherMode() == "UI" then
        field.Parent = self.Panel
        field.ZIndex = 0
    end
    self._weatherParticles = {}
    self._weatherFrameClock = 0
    self._weatherFrameConn = RunService.RenderStepped:Connect(function(dt)
        if self._destroyed then return end
        if not self._visible or self:GetWeather() == "None"
            or (self:GetWeatherMode() == "UI" and not self._open)
            or #self._weatherParticles == 0 then
            self._weatherField.Visible = false
            return
        end
        self._weatherField.Visible = true
        self._weatherFrameClock += math.min(dt, .05)
        -- Capped to 30 updates/sec; particles do not animate a single text container.
        if self._weatherFrameClock < (1 / 30) then return end
        local step = math.min(self._weatherFrameClock, 1 / 15)
        self._weatherFrameClock = 0
        local size = self:_weatherSize()
        local w, h = size.X, size.Y
        local speed = self:GetWeatherSpeed()
        local mode = self:GetWeather()
        for _, particle in self._weatherParticles do
            particle.Clock += step
            particle.X += particle.VX * step * speed
            particle.Y += particle.VY * step * speed
            particle.Rot += particle.Twirl * step * speed
            local margin = math.max(particle.Width, particle.Height)
            if particle.Life then particle.Age += step end
            if (particle.Life and particle.Age >= particle.Life)
                or (not particle.Life and
                    ((particle.VY > 0 and particle.Y > h + margin)
                    or (particle.VY < 0 and particle.Y < -margin))) then
                self:_seedWeatherParticle(mode, particle, false)
            end
            if particle.X > w + margin * 4 then particle.X = -margin end
            if particle.X < -margin * 4 then particle.X = w + margin end
            local x = particle.X
            if particle.Sway > 0 then x += math.sin(particle.Clock * particle.Freq + particle.Phase) * particle.Sway end
            particle.Gui.Position = UDim2.fromOffset(math.floor(x + .5), math.floor(particle.Y + .5))
            if mode ~= "Rain" then particle.Gui.Rotation = particle.Rot end
            local alpha = particle.Alpha
            if mode == "Fireflies" then
                alpha = math.clamp(alpha + math.sin(particle.Clock * 2 + particle.Phase) * .18, 0, .95)
            elseif mode == "Ember" then
                alpha = math.clamp(alpha + (1 - particle.Y / math.max(h, 1)) * .55, 0, .95)
            end
            local transparency = 1 - (1 - alpha) * self:GetWeatherOpacity()
            if mode == "Matrix" then
                particle.Gui.TextTransparency = transparency
            else
                particle.Gui.BackgroundTransparency = transparency
            end
        end
    end)
end

function Hub:GetWeatherOpacity()
    return math.clamp(tonumber(self._weatherOpacity
        or (self.SetupData and self.SetupData.WeatherOpacity)
        or (self.Options and self.Options.WeatherOpacity)) or .7, .05, 1)
end

function Hub:SetWeather(name)
    if self._destroyed then return false, "hub destroyed" end
    local kind = wxName(name)
    if not kind then return false, "unknown weather effect" end
    self._weatherKind = kind
    self:_savePref("Weather", kind)
    if kind == "None" then
        -- Stop the render callback and free the spare ScreenGui immediately.
        self:_disposeWeather()
        return true
    end
    self:_ensureWeather()
    self:_rebuildWeather()
    return true
end

function Hub:SetWeatherMode(mode)
    if self._destroyed then return false, "hub destroyed" end
    if mode ~= "Screen" and mode ~= "UI" then return false, "mode must be Screen or UI" end
    self._weatherMode = mode
    self:_savePref("WeatherMode", mode)
    if self._weatherField then
        self._weatherField.Parent = mode == "UI" and self.Panel or self._weatherScreen
        self._weatherField.ZIndex = 0
        self:_rebuildWeather()
    end
    return true
end

function Hub:SetWeatherDensity(density)
    if self._destroyed then return false, "hub destroyed" end
    local n = tonumber(density)
    if not n then return false, "invalid density" end
    self._weatherDensity = math.clamp(n, 0, 2)
    self:_savePref("WeatherDensity", self._weatherDensity)
    if self._weatherField then self:_rebuildWeather() end
    return true
end

function Hub:SetWeatherSpeed(speed)
    if self._destroyed then return false, "hub destroyed" end
    local n = tonumber(speed)
    if not n then return false, "invalid speed" end
    self._weatherSpeed = math.clamp(n, .25, 2.5)
    self:_savePref("WeatherSpeed", self._weatherSpeed)
    return true
end

function Hub:SetWeatherOpacity(opacity)
    if self._destroyed then return false, "hub destroyed" end
    local n = tonumber(opacity)
    if not n then return false, "invalid opacity" end
    self._weatherOpacity = math.clamp(n, .05, 1)
    self:_savePref("WeatherOpacity", self._weatherOpacity)
    return true
end

function Hub:_disposeWeather()
    if self._weatherFrameConn then
        self._weatherFrameConn:Disconnect()
        self._weatherFrameConn = nil
    end
    if self._weatherField then self:_clearWeatherParticles() end
    if self._weatherScreen then self._weatherScreen:Destroy() end
    self._weatherScreen = nil
    self._weatherField = nil
end

end

-- Resolve forwarded Section aliases from prior Reinitialize calls before
-- recording new controls. Otherwise the next replay cannot find their owner.
local function canonicalRecipeObject(value)
	local hops = 0
	while type(value) == "table" and hops < 16 do
		local mt = getmetatable(value)
		-- Ordinary Section/Tab objects use a class __index; only the
		-- reinitialize forwarders have identical table __index/__newindex.
		local nextTarget = type(mt) == "table" and mt.__index == mt.__newindex
			and mt.__index or nil
		if type(nextTarget) ~= "table" or nextTarget == value then break end
		value = nextTarget
		hops += 1
	end
	return value
end
function Hub:_record(target, method: string, args, result)
	if target._internal or result._internal or self._replaying then
		return
	end
	table.insert(self._recipe, { Target = canonicalRecipeObject(target), Method = method, Args = args, Result = result })
end

function Hub:_buildHeader()
	local theme = self.Theme
	local header = create("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 56),
		Parent = self.Panel,
	}, { padding(0, 10, 0, 16) })
	self.HeaderChip = create("Frame", {
		Name = "Chip",
		BackgroundColor3 = themeColor(theme, "Tile"),
		Position = UDim2.fromOffset(0, 12),
		Size = UDim2.fromOffset(32, 32),
		Parent = header,
	}, { corner(8), stroke(themeColor(theme, "TileStroke")) })
	self.HeaderTitle = text({
		Parent = header,
		Name = "Title",
		FontFace = inter(Enum.FontWeight.SemiBold),
		TextSize = 14,
		Position = UDim2.fromOffset(44, 12),
		Size = UDim2.new(1, -150, 0, 17),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	self.HeaderSub = text({
		Parent = header,
		Name = "Description",
		TextSize = 12,
		TextColor3 = themeColor(theme, "SubText"),
		Position = UDim2.fromOffset(44, 30),
		Size = UDim2.new(1, -150, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	create("Frame", {
		Name = "Rule",
		BackgroundColor3 = themeColor(theme, "Divider"),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, -16, 1, 0),
		Size = UDim2.new(1, 26, 0, 1),
		Parent = header,
	})
	self.Search = create("TextBox", {
		Name = "Search",
		BackgroundColor3 = themeColor(theme, "Field"),
		Position = UDim2.fromOffset(0, 12),
		Size = UDim2.new(1, -78, 0, 32),
		FontFace = inter(),
		TextSize = 13,
		TextColor3 = themeColor(theme, "Text"),
		PlaceholderText = "Search this tab",
		PlaceholderColor3 = themeColor(theme, "Muted"),
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = false,
		Parent = header,
	}, { corner(8), stroke(themeColor(theme, "FieldStroke")), padding(0, 10) })
	local actions = create("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 14),
		Size = UDim2.fromOffset(64, 28),
		Parent = header,
	}, { list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right) })
	local function action(icon: string, fallback: string, order: number, fn)
		local b = create("TextButton", {
			Name = icon,
			BackgroundColor3 = themeColor(theme, "Tile"),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(28, 28),
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Parent = actions,
		}, { corner(7) })
		local img = iconLabel(icon, 16, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
		if img then
			img.Parent = b
		else
			text({ Parent = b, Text = fallback, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = themeColor(theme, "SubText") })
		end
		self:_connect(b.MouseEnter, function()
			tween(b, FAST, { BackgroundTransparency = 0 })
			if img then
				setThemed(img, "ImageColor3", themeColor(theme, "Text"))
			end
		end)
		self:_connect(b.MouseLeave, function()
			tween(b, FAST, { BackgroundTransparency = 1 })
			if img then
				setThemed(img, "ImageColor3", themeColor(theme, "SubText"))
			end
		end)
		self:_connect(b.MouseButton1Click, fn)
		return b
	end
	action("search", "?", 1, function()
		self:_toggleSearch()
	end)
	action("x", "x", 2, function()
		self:Close()
	end)
	self:_connect(self.Search:GetPropertyChangedSignal("Text"), function()
		self:_applySearch(self.Search.Text)
	end)
	self:_connect(self.Search.FocusLost, function()
		if self.Search.Text == "" then
			self:_toggleSearch(false)
		end
	end)
end

function Hub:_toggleSearch(force: boolean?)
	local on = if force ~= nil then force else not self.Search.Visible
	self.Search.Visible = on
	self.HeaderTitle.Visible = not on
	self.HeaderChip.Visible = not on
	local caption = self._open and self:_contentTab(self._open)
	self.HeaderSub.Visible = not on and caption ~= nil and ((caption.IsSubTab and caption.Name) or self._open.Description or "") ~= ""
	if on then
		self.Search:CaptureFocus()
	else
		self.Search.Text = ""
		self:_applySearch("")
	end
end

function Hub:_applySearch(query: string)
	local parent = self._open
	if not parent then return end
	local tab = self:_contentTab(parent)
	query = string.lower(query)
	for _, section in tab.Sections do
		local any = false
		local matchedCards = {}
		local matchedGroups = {}
		for _, control in section.Controls do
			if control._isModuleCard then continue end
			local matched = query == "" or string.find(string.lower(control.Name or ""), query, 1, true) ~= nil
            if not matched and control.Type == "Accordion" and control.MatchesSearch then
                matched = control:MatchesSearch(query)
            end
			local group = control.Section
			while group and group._isGroup do
				if query ~= "" and string.find(string.lower(group.Name), query, 1, true) then
					matched = true
				end
				group = group.Parent
			end
			local ancestor = control._moduleCard
			while ancestor do
				if query ~= "" and string.find(string.lower(ancestor.Name), query, 1, true) then
					matched = true
				end
				ancestor = ancestor._parentCard
			end
			control.Frame.Visible = matched and not control._hidden
            if control.Type == "Accordion" and control._setSearchPeek then
                control:_setSearchPeek(query ~= "" and matched, query)
            end
			if matched and not control._hidden then
				any = true
				group = control.Section
				while group and group._isGroup do
					matchedGroups[group] = true
					group = group.Parent
				end
				ancestor = control._moduleCard
				while ancestor do
					matchedCards[ancestor] = true
					ancestor = ancestor._parentCard
				end
			end
		end
		for _, control in section.Controls do
			if control._isModuleCard then
				local matched = query == "" or
					string.find(string.lower(control.Name), query, 1, true) ~= nil or
					matchedCards[control] == true
				if not matched and query ~= "" then
					local ancestor = control._parentCard
					while ancestor do
						if string.find(string.lower(ancestor.Name), query, 1, true) then
							matched = true
							break
						end
						ancestor = ancestor._parentCard
					end
				end
				control.Frame.Visible = matched and not control._hidden and not control._dependencyHidden
				control:_setSearchPeek(query ~= "" and matched)
				any = any or control.Frame.Visible
			end
		end
		-- Group rows and module cards share a root control registry. Reopen
		-- only matched Group ancestors without mutating the user's open state.
		for _, control in section.Controls do
			local group = control.Section
			while group and group._isGroup do
				group:_setSearchPeek(query ~= "" and matchedGroups[group] == true)
				group = group.Parent
			end
		end
		section.Frame.Visible = (any or query == "") and not section.Pinned
		local peek = query ~= "" and any
		if section._peek ~= peek then
			section._peek = peek
			section:_applyCollapse(false)
		end
	end
	task.defer(function()
		if not self._destroyed and self._open == parent then self:_fitPanel(parent, false) end
	end)
end

---------------------------------------------------------------- input: click-off, toggle key
do
-- RelaxUI overlay stack and unified global input router.
-- One registration per overlay; local widget pointer/drag interactions are kept intact.
-- Match the actual root-layer ZIndex order (ScreenGui uses Sibling).
-- A later API call may create an overlay behind a still-visible modal;
-- its input priority must NOT jump in front of the visible modal.
local INPUT_OVERLAY_PRIORITY = {
    SubTabs = 40,
    Window = 79,
    CommandPalette = 81,
    Setup = 95,
    Popup = 98,
    Prompt = 100,
}

local function overlayRelease(item)
    if item.DestroyConnection then
        item.DestroyConnection:Disconnect()
        item.DestroyConnection = nil
    end
end

local function overlayView(owner)
    if typeof(owner) == "Instance" then return owner end
    if type(owner) == "table" then return owner.Layer end
    return nil
end

function Hub:_overlayStackInit()
    if not self._overlayStack then
        self._overlayStack = {}
        self._overlaySerial = 0
    end
    return self._overlayStack
end

function Hub:_overlayRegister(kind, owner, options)
    assert(INPUT_OVERLAY_PRIORITY[kind], "unknown overlay kind")
    assert(owner ~= nil, "overlay owner is required")
    local stack = self:_overlayStackInit()
    -- Re-registering an owner changes its order without retaining old
    -- Destroying subscriptions or producing duplicate stack entries.
    self:_overlayUnregister(kind, owner)
    self._overlaySerial += 1
    local item = {
        Kind = kind, Owner = owner, Serial = self._overlaySerial,
        Priority = INPUT_OVERLAY_PRIORITY[kind],
        Content = options and options.Content,
        Anchor = options and options.Anchor,
        Close = options and options.Close,
        Outside = options and options.Outside ~= false,
        Escape = options and options.Escape ~= false,
        Modal = options and options.Modal == true,
    }
    local target = overlayView(owner)
    if target and target.Destroying then
        item.DestroyConnection = target.Destroying:Connect(function()
            self:_overlayUnregister(kind, owner)
        end)
    end
    local index = #stack + 1
    for i, existing in stack do
        if item.Priority < existing.Priority then
            index = i
            break
        end
    end
    table.insert(stack, index, item)
    return item
end

function Hub:_overlayUnregister(kind, owner)
    local stack = self._overlayStack
    if not stack then return false end
    local removed = false
    for i = #stack, 1, -1 do
        local item = stack[i]
        if (kind == nil or item.Kind == kind)
            and (owner == nil or item.Owner == owner) then
            table.remove(stack, i)
            overlayRelease(item)
            removed = true
        end
    end
    return removed
end

function Hub:_overlayTop()
    local stack = self._overlayStack
    return stack and stack[#stack] or nil
end

function Hub:GetOverlayStack()
    local snapshot = {}
    for i, item in self._overlayStack or {} do
        snapshot[i] = { Kind = item.Kind, Serial = item.Serial }
    end
    return snapshot
end

function Hub:_overlayContains(target, position)
    if not target or not target.Parent or target.Visible == false then return false end
    return within(target, position)
end

function Hub:_overlayDismiss(item, reason)
    if not item or self._overlayClosing then return false end
    local top = self:_overlayTop()
    if top ~= item then return false end
    self._overlayClosing = true
    local ok, err = pcall(function()
        if item.Close then item.Close(reason) end
    end)
    self._overlayClosing = false
    if not ok then warn("[RelaxUI OverlayStack] " .. tostring(err)) end
    -- Close callbacks normally unregister their own entry. If an owner failed
    -- or was already destroyed, discard the stale layer to prevent deadlocks.
    if self:_overlayTop() == item then
        self:_overlayUnregister(item.Kind, item.Owner)
    end
    return true
end

function Hub:_routeOverlayKey(key)
    local top = self:_overlayTop()
    if key ~= Enum.KeyCode.Escape then return false end
    if top then
        if top.Escape then return self:_overlayDismiss(top, "escape") end
        return true
    end
    if self._open then self:Close(); return true end
    return false
end

function Hub:_routeOverlayPointer(position)
    local top = self:_overlayTop()
    if not top then
        -- The orb is only interactive without a blocking overlay in front.
        return self.Restore and self:_overlayContains(self.Restore, position) or false
    end
    if self:_overlayContains(top.Content, position) then return true end
    if self:_overlayContains(top.Anchor, position) then return true end
    -- Only one layer can dismiss for a single pointer-down. Do not forward
    -- this same gesture to the panel or to overlays underneath it.
    if top.Outside then self:_overlayDismiss(top, "outside") end
    return true
end

function Hub:_overlayClear()
    self._overlayClosing = false
    if self._overlayStack then
        for _, entry in self._overlayStack do overlayRelease(entry) end
        table.clear(self._overlayStack)
    end
end

end
function Hub:_bindInput()
	self:_overlayStackInit()
	self:_connect(UserInputService.InputBegan, function(input, gameProcessed)
		if self._destroyed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			-- Escape routes to the top overlay before any keybind or focus check.
			-- Setup and in-progress keybind capture consume Esc by policy.
			if input.KeyCode == Enum.KeyCode.Escape then
				if self:_overlayTop() then self:_routeOverlayKey(input.KeyCode)
				elseif not self._listening and not UserInputService:GetFocusedTextBox() then
					self:_routeOverlayKey(input.KeyCode)
				end
				return
			end
			if self._listening then return end
			if gameProcessed or UserInputService:GetFocusedTextBox() then return end
			local top = self:_overlayTop()
			if input.KeyCode == self.CommandKey then
				-- A modal Prompt/Window/Setup has priority; never close an
				-- obscured command palette or open one through another overlay.
				if top and top.Kind ~= "CommandPalette" then return end
				if self._palette then self:CloseCommandPalette()
				else self:OpenCommandPalette() end
				return
			end
			if top then return end
			if input.KeyCode == self.ToggleKey then
				self:SetToolbarVisible(not self._visible)
			end
			return
		end
		if not isPointer(input) then return end
		if self:_routeOverlayPointer(Vector2.new(input.Position.X, input.Position.Y)) then return end
		if self._open and not within(self.PanelHolder, Vector2.new(input.Position.X, input.Position.Y))
			and not within(self.Dock, Vector2.new(input.Position.X, input.Position.Y))
			and not self._popupJustClosed then
			self:Close()
		end
	end)
end

function Hub:_dockBottom()
	return UserInputService.TouchEnabled and 68 or 40
end

function Hub:SetToolbarVisible(visible: boolean, quiet: boolean?)
	if not visible then self:_closeSubTabs() end
	if self._visible == visible then
		return
	end
	if self._loading then
		-- the dock comes up when loading ends; until then only remember the choice
		self._visible = visible
		self:_syncToolbarOrbState(false)
		return
	end
	self._visible = visible
	self:_syncToolbarOrbState(true)
	self.Restore.Visible = UserInputService.TouchEnabled
	local holder = self.DockHolder
	if visible then
		holder.Position = UDim2.new(0.5, 0, 1, -self:_dockBottom())
		holder.Visible = true
	else
		self:Close()
		self:_closePopup()
		self.Tooltip.Visible = false
		-- Hide the text-containing dock without animating its screen position.
		holder.Visible = false
		if not UserInputService.TouchEnabled and not quiet then
			self:Notify({
				Title = "Toolbar hidden",
				Content = "Press " .. keyName(self.ToggleKey) .. " to bring it back.",
				Duration = 3,
			})
		end
	end
end

function Hub:ToggleToolbar()
	self:SetToolbarVisible(not self._visible)
end

do
-- RelaxUI: animated compact toolbar orb, event-driven while idle.
local ORB_GREEN = Color3.fromRGB(71, 233, 130)
local ORB_RED = Color3.fromRGB(255, 91, 105)
local ORB_PRESS = TweenInfo.new(.13, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ORB_SETTLE = TweenInfo.new(.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local ORB_MORPH = TweenInfo.new(.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ORB_RIPPLE = TweenInfo.new(.52, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ORB_HOLD_SECONDS = 1
local ORB_CANCEL_DISTANCE = 11

function Hub:_setToolbarOrbPosition(x, y)
    if not self.Restore then return end
    local v = viewport()
    if v.X <= 0 or v.Y <= 0 then return end
    local edge = 22 * (self._scale or 1) + 10
    local minX = math.min(.49, edge / v.X)
    local minY = math.min(.49, (topInset() + edge) / v.Y)
    local maxY = math.max(minY, 1 - edge / v.Y)
    x = math.clamp(x, minX, 1 - minX)
    y = math.clamp(y, minY, maxY)
    self.Restore.Position = UDim2.fromScale(x, y)
    self._toolbarOrbPosition = { X = x, Y = y }
end

function Hub:_refreshToolbarOrbTheme()
    if not self._orbGradient or self._destroyed then return end
    local theme = self.Theme
    local accent = theme.Accent or theme.Text or Color3.fromRGB(245, 245, 245)
    local surface = theme.TileActive or theme.PanelStroke or accent
    local highlight = theme.Highlight or theme.Text or accent
    local h, saturation, value = accent:ToHSV()
    local primary = saturation < .12 and Color3.fromRGB(93, 178, 246) or accent
    local secondary = saturation < .12 and Color3.fromRGB(180, 132, 248)
        or Color3.fromHSV((h + .15) % 1, math.max(.38, saturation * .82), math.max(.72, value))
    local colors = ColorSequence.new({
        ColorSequenceKeypoint.new(0, primary),
        ColorSequenceKeypoint.new(.25, accent:Lerp(highlight, .20)),
        ColorSequenceKeypoint.new(.52, secondary),
        ColorSequenceKeypoint.new(.76, surface:Lerp(primary, .72)),
        ColorSequenceKeypoint.new(1, primary),
    })
    self._orbGradient.Color = colors
    self._orbHaloGradient.Color = colors
    if not self._toolbarOrbHolding then
        self._orbBorder.Color = accent
        self._orbHaloStroke.Color = accent
    end
end

function Hub:_setToolbarOrbSpin(enabled)
    if not self._orbSpinTween then return end
    if enabled and not self._toolbarOrbHolding then
        self._orbSpinTween:Play()
        self._orbHaloSpinTween:Play()
    else
        self._orbSpinTween:Pause()
        self._orbHaloSpinTween:Pause()
    end
end

function Hub:_syncToolbarOrbState(animate)
    if not self._orbHorizontal then return end
    local open = self._visible == true
    local tint = open and ORB_RED or ORB_GREEN
    if animate then
        Motion.transition(self, "toolbar-orb-glyph", open and "expanded" or "collapsed", {
            { Target = self._orbHorizontal, Goals = {
                BackgroundColor3 = tint, Rotation = open and 0 or -90,
            } },
            { Target = self._orbVertical, Goals = {
                BackgroundColor3 = tint, BackgroundTransparency = open and 1 or 0,
                Rotation = open and 90 or 0,
            } },
        }, ORB_MORPH)
    else
        Motion.cancel(self, "toolbar-orb-glyph")
        self._orbHorizontal.BackgroundColor3 = tint
        self._orbHorizontal.Rotation = open and 0 or -90
        self._orbVertical.BackgroundColor3 = tint
        self._orbVertical.BackgroundTransparency = open and 1 or 0
        self._orbVertical.Rotation = open and 90 or 0
    end
end

function Hub:_toolbarOrbRipple(color, unlocked)
    if self._destroyed or not self.Restore or not self.Restore.Parent then return end
    local ripple = create("Frame", {
        Name = unlocked and "DragUnlockRipple" or "ToggleRipple",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(44, 44), ZIndex = 34, Parent = self.Restore,
    }, { corner(100) })
    local ring = stroke(color, unlocked and 2.7 or 1.8, unlocked and .04 or .3)
    ring.Parent = ripple
    local size = unlocked and 94 or 71
    tween(ripple, ORB_RIPPLE, { Size = UDim2.fromOffset(size, size) })
    tween(ring, ORB_RIPPLE, { Transparency = 1, Thickness = .6 })
    task.delay(ORB_RIPPLE.Time + .05, function()
        if ripple.Parent then ripple:Destroy() end
    end)
end

function Hub:_setupToolbarOrb()
    local orb = self.Restore
    local face = create("Frame", {
        Name = "OrbFace", BackgroundColor3 = Color3.fromRGB(8, 9, 12),
        BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(36, 36),
        ZIndex = 35, Parent = orb,
    }, { corner(100) })
    self._orbFace = face
    self._orbBorder = stroke(self.Theme.Accent, 2.1)
    self._orbBorder.Name = "ThemeGradientBorder"
    self._orbBorder.Parent = face
    self._orbGradient = create("UIGradient", { Rotation = 0, Parent = self._orbBorder })
    local halo = create("Frame", {
        Name = "OrbHalo", BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(46, 46), ZIndex = 34, Parent = orb,
    }, { corner(100) })
    self._orbHaloStroke = stroke(self.Theme.Accent, 1.3, .8)
    self._orbHaloStroke.Parent = halo
    self._orbHaloGradient = create("UIGradient", { Rotation = 0, Parent = self._orbHaloStroke })
    self._orbScale = create("UIScale", { Scale = 1, Parent = orb })
    local spin = TweenInfo.new(6.8, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
    local haloSpin = TweenInfo.new(10.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
    self._orbSpinTween = TweenService:Create(self._orbGradient, spin, { Rotation = 360 })
    self._orbHaloSpinTween = TweenService:Create(self._orbHaloGradient, haloSpin, { Rotation = -360 })
    self:Own({ Disconnect = function()
        self._orbSpinTween:Cancel()
        self._orbHaloSpinTween:Cancel()
    end })
    self._orbHorizontal = create("Frame", {
        Name = "GlyphHorizontal", BackgroundColor3 = ORB_RED, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(17, 3), ZIndex = 37, Parent = orb,
    }, { corner(3) })
    self._orbVertical = create("Frame", {
        Name = "GlyphVertical", BackgroundColor3 = ORB_RED, BorderSizePixel = 0,
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(3, 17),
        ZIndex = 37, Parent = orb,
    }, { corner(3) })
    self:_refreshToolbarOrbTheme()
    self:_syncToolbarOrbState(false)
    self:_setToolbarOrbSpin(UserInputService.TouchEnabled)

    local saved = self.SetupData and self.SetupData.ToolbarOrbPosition
    if type(saved) == "table" and type(saved.X) == "number" and type(saved.Y) == "number"
        and saved.X == saved.X and saved.Y == saved.Y then
        self:_setToolbarOrbPosition(saved.X, saved.Y)
    end
    local function reclamp()
        if self._toolbarOrbPosition and not self._destroyed then
            self:_setToolbarOrbPosition(self._toolbarOrbPosition.X, self._toolbarOrbPosition.Y)
        end
    end
    self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), reclamp)
    self:_connect(self.UIScale:GetPropertyChangedSignal("Scale"), reclamp)

    local press, generation = nil, 0
    local dragBinding = {}
    local function dragStyle(on)
        self._toolbarOrbHolding = on
        self._orbGradient.Enabled = not on
        self._orbHaloGradient.Enabled = not on
        self:_setToolbarOrbSpin(not on and UserInputService.TouchEnabled)
        if on then
            self._orbBorder.Color = ORB_GREEN
            self._orbHaloStroke.Color = ORB_GREEN
            tween(self._orbBorder, ORB_PRESS, { Thickness = 2.9 })
            tween(self._orbHaloStroke, ORB_PRESS, { Transparency = .17 })
            tween(self._orbScale, ORB_SETTLE, { Scale = 1.075 })
        else
            self:_refreshToolbarOrbTheme()
            tween(self._orbBorder, ORB_MORPH, { Thickness = 2.1 })
            tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
            tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
        end
    end

    local finish
    finish = function(cancelled, position)
        local p = press
        if not p then return end
        press = nil
        generation += 1 -- invalidates the pending long-press unlock
        if p.stateConn then p.stateConn:Disconnect() end
        if self._capturedDrag == dragBinding then self._capturedDrag = nil end
        if self._activeDrags then self._activeDrags[dragBinding] = nil end
        if p.unlocked then
            dragStyle(false)
            if p.dragged and not self._destroyed then
                local pos = self._toolbarOrbPosition
                if pos then self:_savePref("ToolbarOrbPosition", { X = pos.X, Y = pos.Y }) end
            end
        else
            tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
            tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
        end
        if not cancelled and not p.unlocked and not p.invalid and not self._destroyed
            and within(orb, position or p.last) then
            self:_toolbarOrbRipple(self._visible and ORB_RED or ORB_GREEN, false)
            self:ToggleToolbar()
        end
    end
    dragBinding.Cancel = function() finish(true) end
    self:Own({ Disconnect = function() finish(true) end })

    self:_connect(orb.InputBegan, function(input)
        if self._destroyed or self._loading or press or self._capturedDrag
            or self:_overlayTop() or not isPointer(input) then return end
        generation += 1
        local token = generation
        local down = Vector2.new(input.Position.X, input.Position.Y)
        local origin = self._toolbarOrbPosition
        if not origin then
            local center = orb.AbsolutePosition + orb.AbsoluteSize * .5
            local v = viewport()
            origin = { X = center.X / math.max(v.X, 1), Y = center.Y / math.max(v.Y, 1) }
        end
        press = { input = input, down = down, last = down,
            origin = { X = origin.X, Y = origin.Y }, invalid = false,
            unlocked = false, dragged = false }
        local p = press
        if input.UserInputType == Enum.UserInputType.Touch then
            p.stateConn = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
                if press ~= p then return end
                if input.UserInputState == Enum.UserInputState.Cancel then finish(true)
                elseif input.UserInputState == Enum.UserInputState.End then finish(false, p.last) end
            end)
        end
        tween(self._orbScale, ORB_PRESS, { Scale = .92 })
        tween(self._orbHaloStroke, ORB_PRESS, { Transparency = .43 })
        task.delay(ORB_HOLD_SECONDS, function()
            if self._destroyed or press ~= p or generation ~= token or p.invalid or not orb.Parent then return end
            if self._capturedDrag or self:_overlayTop() then finish(true); return end
            p.unlocked = true
            self._capturedDrag = dragBinding
            self._activeDrags = self._activeDrags or {}
            self._activeDrags[dragBinding] = true
            self:_toolbarOrbRipple(ORB_GREEN, true)
            dragStyle(true)
        end)
    end)
    self:_connect(UserInputService.InputChanged, function(input)
        local p = press
        if not p or self._destroyed then return end
        if self:_overlayTop() then finish(true); return end
        local touch = p.input.UserInputType == Enum.UserInputType.Touch
        if (touch and input ~= p.input)
            or (not touch and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
        local point = Vector2.new(input.Position.X, input.Position.Y)
        p.last = point
        local delta = point - p.down
        if not p.unlocked then
            if delta.Magnitude > ORB_CANCEL_DISTANCE and not p.invalid then
                p.invalid = true
                generation += 1
                tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
                tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
            end
            return
        end
        if delta.Magnitude >= 2 then p.dragged = true end
        local v = viewport()
        self:_setToolbarOrbPosition(p.origin.X + delta.X / math.max(v.X, 1),
            p.origin.Y + delta.Y / math.max(v.Y, 1))
    end)
    self:_connect(UserInputService.InputEnded, function(input)
        local p = press
        if not p then return end
        local touch = p.input.UserInputType == Enum.UserInputType.Touch
        if (touch and input == p.input)
            or (not touch and input.UserInputType == Enum.UserInputType.MouseButton1) then
            finish(input.UserInputState == Enum.UserInputState.Cancel,
                Vector2.new(input.Position.X, input.Position.Y))
        end
    end)
    self:_connect(orb.MouseEnter, function()
        if press or self._destroyed then return end
        tween(self._orbScale, ORB_MORPH, { Scale = 1.065 })
        tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .43 })
    end)
    self:_connect(orb.MouseLeave, function()
        if press or self._destroyed then return end
        tween(self._orbScale, ORB_SETTLE, { Scale = 1 })
        tween(self._orbHaloStroke, ORB_MORPH, { Transparency = .77 })
    end)
end

end

---------------------------------------------------------------- open / close
-- Panel height for a tab and its centred position, kept clear of the dock and the topbar.
function Hub:_panelGeometry(tab)
	local s = self._scale
	local vp = viewport() / s
	local top = topInset() / s + 12
	local bottom = vp.Y - self:_dockBottom() - 50 - 16
	local content = self:_contentTab(tab)
	local measuredHeight = content.Columns.Frame.AbsoluteSize.Y / s
	if measuredHeight > 0 then content._lastMeasuredHeight = measuredHeight end
	-- Layout can report zero on the first frame after a page becomes visible.
	-- Preserve its last valid measurement (or the previous panel height) rather
	-- than momentarily shrinking to 120px while Roblox resolves UIListLayout.
	local contentHeight = measuredHeight > 0 and measuredHeight or content._lastMeasuredHeight
    -- Do not derive a newly opened page's default height from the PREVIOUS
    -- page's PanelHolder: that would cause implicit cross-tab size sharing.
    if not contentHeight and #content.Sections > 0 then
        contentHeight = 322
    end
	local maxHeight = math.max(bottom - top, 160)
    local h = math.max(58 + (contentHeight or 0), math.min(380, maxHeight))
    local pageSize = self:_panelSizeFor(tab)
    if pageSize then h = pageSize.Height end
    h = math.clamp(h, math.min(260, maxHeight), maxHeight)
	local cy = math.clamp(vp.Y / 2, top + h / 2, math.max(top + h / 2, bottom - h / 2))
	-- Primary and child pages share one geometry calculation.
	-- Content height may vary; no secondary-only anchoring or special spacing.
	return h, cy
end

function Hub:_fitPanel(tab, animate: boolean)
	tab = self:_contentTab(tab)
	-- Settings needs wider columns for long labels, sliders and dropdown values.
	-- On phones it remains a single scrolling column; desktop gets ~280px
	-- per column instead of the previous ~200px fixed-width split.
	local logicalWidth = viewport().X / self._scale
	local settings = tab == self.SettingsTab
	local availableWidth = math.max(240, logicalWidth - 24)
    local panelWidth = math.min(settings and 680 or 620, availableWidth)
    local pageSize = self:_panelSizeFor(tab)
    if pageSize then
        panelWidth = math.clamp(pageSize.Width, math.min(340, availableWidth), availableWidth)
    end
    -- Narrow panels reflow instead of squeezing two columns into tiny cards.
    local narrow = panelWidth < 550
	for side = 1, 2 do
		local col = tab.Columns[side]
		local visible = not narrow or side == 1
		local size = narrow and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -9, 0, 0)
		if col.Visible ~= visible then col.Visible = visible end
		if col.Size ~= size then col.Size = size end
	end
	for i, section in tab.Sections do
		if not section.Pinned then
			local parent = tab.Columns[narrow and 1 or section.Side + 1]
			if section.Frame.Parent ~= parent then section.Frame.Parent = parent end
			if section.Frame.LayoutOrder ~= i then section.Frame.LayoutOrder = i end
		end
	end
	local h, cy = self:_panelGeometry(tab)
	local goalSize = UDim2.fromOffset(panelWidth, h)
	local goalPos = UDim2.new(0.5, 0, 0, cy)
	if animate then
		Motion.play(self, "panel-geometry", self.PanelHolder,
			{ Size = goalSize, Position = goalPos }, SETTLE)
	else
		Motion.cancel(self, "panel-geometry")
		if self.PanelHolder.Size ~= goalSize then self.PanelHolder.Size = goalSize end
		if self.PanelHolder.Position ~= goalPos then self.PanelHolder.Position = goalPos end
	end
end

-- horizontal pull toward the tile that owns the panel, for the rise and fold motion
function Hub:_requestPanelFit()
	if self._panelFitPending or self._destroyed then return end
	self._panelFitPending = true
	task.defer(function()
		self._panelFitPending = false
		if not self._destroyed and self._open then self:_fitPanel(self._open, false) end
	end)
end

function Hub:_tileOffset(tab): number
	local s = self._scale
	local tp, ts = tab.Tile.AbsolutePosition, tab.Tile.AbsoluteSize
	return ((tp.X + ts.X / 2) - viewport().X / 2) / s * 0.22
end

function Hub:Open(tab)
	if type(tab) == "string" then
		for _, t in self.Tabs do
			if t.Name == tab then
				tab = t
				break
			end
		end
	end
	if type(tab) ~= "table" then return end
	if tab.IsSubTab then
		if self._open ~= tab.ParentTab then self:Open(tab.ParentTab) end
		return self:_setSubTab(tab.ParentTab, tab)
	end
	if self._open == tab then return end
	if self._loading then
		self:_afterLoading(function() if not self._destroyed then self:Open(tab) end end)
		return
	end
	self:_closeSubTabs()
	local previous = self._open
	if previous then
		self:_contentTab(previous).Page.Visible = false
		previous:_setActive(false)
	end
	self._open = tab
	self:PlayUISound("Tab")
	if not previous then self:PlayUISound("WindowOpen") end
	tab:_setActive(true)
	if self.Search.Visible then
		self:_toggleSearch(false)
	end
	self.HeaderTitle.Text = tab.Name
	self:_updateTabHeader(tab)
	self.HeaderChip:ClearAllChildren()
	corner(8).Parent = self.HeaderChip
	stroke(self.Theme.TileStroke).Parent = self.HeaderChip
	if not iconLabel(tab.Icon, 16, self.Theme.Text, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = self.HeaderChip }) then
		text({ Parent = self.HeaderChip, Text = string.upper(string.sub(tab.Name, 1, 1)), FontFace = inter(Enum.FontWeight.SemiBold), Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
	end
	local currentPage = self:_contentTab(tab)
	currentPage.Page.Visible = true
	currentPage.Scroll.CanvasPosition = Vector2.zero
	self.Tooltip.Visible = false

	if previous then
		-- Avoid animating text layout or ScrollingFrame offsets during tab changes.
		self:_fitPanel(tab, false)
		-- UIListLayout and text wrapping may settle one frame after the page switch.
		-- _requestPanelFit always targets the current tab, so stale requests from
		-- a previous page cannot resize the newly selected page.
		self:_requestPanelFit()
		tab.Scroll.Position = UDim2.fromOffset(0, 0)
		return
	end
	local holder = self.PanelHolder
	local wasVisible = holder.Visible
	holder.Visible = true
	-- Reopening mid-fold continues from current transparency, not from 100%.
	self:_fitPanel(tab, false)
	self:_requestPanelFit()
	self.PanelRise.Scale = 1
	if not wasVisible then
		-- Keep the text and rounded panel surface fully rendered from frame one.
		-- Fade only the decorative border and shadow, never rasterized text.
		self.PanelOutlineStroke.Transparency = 1
		if self.PanelShadow then self.PanelShadow.ImageTransparency = 1 end
	end
	local steps = {
		{ Target = self.PanelOutlineStroke, Goals = { Transparency = 0 } },
	}
	if self.PanelShadow then
		table.insert(steps, { Target = self.PanelShadow, Goals = { ImageTransparency = 0.1 } })
	end
	Motion.transition(self, "panel-visibility", "open", steps, RISE)
end

function Hub:Close()
	local tab = self._open
	if not tab then
		return
	end
	self:_closeSubTabs()
	self._open = nil
	self:PlayUISound("WindowClose")
	tab:_setActive(false)
	self:_closePopup()
	if self.Search.Visible then
		self:_toggleSearch(false)
	end
	local holder = self.PanelHolder
	self.PanelRise.Scale = 1
	-- A single state owns the fade, outline and shadow. Stale close callbacks
	-- cannot hide a panel that was reopened during its exit animation.
	local steps = {
		{ Target = self.PanelOutlineStroke, Goals = { Transparency = 1 } },
	}
	if self.PanelShadow then
		table.insert(steps, { Target = self.PanelShadow, Goals = { ImageTransparency = 1 } })
	end
	Motion.transition(self, "panel-visibility", "closed", steps, FOLD, function()
		if self._open == nil then
			holder.Visible = false
			self:_contentTab(tab).Page.Visible = false
		end
	end)
end

---------------------------------------------------------------- popups (dropdown lists, color picker)
-- Recompute placement whenever viewport, scale or anchor position changes.
-- A small viewport gets a scrollable popup viewport instead of inaccessible rows.
function Hub:_placePopup(p, animate)
    if self._destroyed or self._popup ~= p or not p.Anchor.Parent then return end
    local scale = math.max(self._scale or 1, .01)
    local vp = viewport() / scale
    local minY = math.max(6, topInset() / scale + 6)
    local floorY = math.max(minY + 48, vp.Y - 8)
    if self._visible and self.DockHolder.Visible then
        floorY = math.max(minY + 48,
            math.min(floorY, self.Dock.AbsolutePosition.Y / scale - 8))
    end
    -- Content-anchored menus must not drift into the window's title/actions.
    -- Reserve the visible Header rather than hardcoding an absolute screen Y.
    -- On very small screens, prioritize a reachable minimum popup height.
    local panel = self.Panel
    if panel and panel.Parent and p.Anchor:IsDescendantOf(panel) then
        local header = panel:FindFirstChild("Header")
        if header and header.Visible then
            local headerBottom = (header.AbsolutePosition.Y + header.AbsoluteSize.Y)
                / scale + 5
            minY = math.min(math.max(minY, headerBottom),
                math.max(minY, floorY - 48))
        end
    end
    local anchorPos, anchorSize = p.Anchor.AbsolutePosition / scale,
        p.Anchor.AbsoluteSize / scale
    local frame = p.Frame
    local logicalSize = frame.AbsoluteSize / scale
    local requestedW = math.max(1, frame.Size.X.Offset, logicalSize.X)
    local requestedH = math.max(1, frame.Size.Y.Offset, logicalSize.Y)
    local width = math.min(requestedW, math.max(48, vp.X - 12))
    -- An optional per-popup placement policy keeps the SearchSelect menu
    -- attached to its field without changing legacy Dropdown/ColorPicker.
    local placement = p.Placement or {}
    local gap = math.clamp(tonumber(placement.Gap) or 6, 0, 16)
    local belowY = anchorPos.Y + anchorSize.Y + gap
    local belowSpace = math.max(0, floorY - belowY)
    local aboveSpace = math.max(0, anchorPos.Y - gap - minY)
    local minimumBelow = math.min(requestedH,
        math.max(48, tonumber(placement.MinimumBelowHeight) or 96))
    local below = belowSpace >= requestedH
        or (placement.PreferBelow == true and belowSpace >= minimumBelow)
        or belowSpace >= aboveSpace
    local available = math.max(48, below and belowSpace or aboveSpace)
    local height = math.min(requestedH, available, math.max(48, floorY - minY))
    local y = below and belowY or anchorPos.Y - gap - height
    y = math.clamp(y, minY, math.max(minY, floorY - height))
    local xTarget = anchorPos.X + anchorSize.X - width
    if placement.Align == "Center" then
        xTarget = anchorPos.X + (anchorSize.X - width) * .5
    elseif placement.Align == "Left" then
        xTarget = anchorPos.X
    end
    local x = math.clamp(xTarget, 6, math.max(6, vp.X - width - 6))
    p.Holder.Size = UDim2.fromOffset(width, height)
    p.Scroll.CanvasSize = UDim2.fromOffset(requestedW, requestedH)
    local goal = UDim2.fromOffset(x, y)
    if animate then
        p.Holder.Position = UDim2.fromOffset(x, y + (below and -6 or 6))
        Motion.play(self, "popup-position", p.Holder, { Position = goal }, SETTLE)
    else
        Motion.cancel(self, "popup-position")
        p.Holder.Position = goal
    end
end

function Hub:_openPopup(anchor: GuiObject, frame: GuiObject, onClose, placement)
    self:_closePopup()
    if self._destroyed or not anchor or not anchor.Parent then return end
    local shield = create("TextButton", {
        Name = "PopupPointerShield", Text = "", AutoButtonColor = false,
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true,
        Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = self.Overlay,
    })
    local holder = create("Frame", {
        Name = "Popup", BackgroundTransparency = 1,
        Size = frame.Size, Active = true, ZIndex = 2, Parent = self.Overlay,
    })
    shadow(holder, 20, 40, 6)
    local scroll = create("ScrollingFrame", {
        Name = "PopupViewport", BackgroundTransparency = 1,
        BorderSizePixel = 0, ClipsDescendants = true,
        ScrollingDirection = Enum.ScrollingDirection.XY,
        ScrollBarThickness = 3,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), ZIndex = 40, Parent = holder,
    })
    frame.Position = UDim2.new()
    frame.Parent = scroll
    local p = {
        Anchor = anchor, Frame = frame, Holder = holder,
        Scroll = scroll, Shield = shield, OnClose = onClose,
        Placement = placement, RepositionConnections = {},
    }
    p.ShieldConnection = shield.MouseButton1Click:Connect(function()
        if self._popup == p then self:_closePopup() end
    end)
    self._popup = p
    self:_overlayRegister("Popup", holder, {
        Content = holder, Anchor = anchor,
        Close = function() self:_closePopup() end,
    })
    local function reposition()
        if self._popup == p then self:_placePopup(p, false) end
    end
    for _, spec in {
        { anchor, "AbsolutePosition" }, { anchor, "AbsoluteSize" },
        { frame, "AbsoluteSize" }, { self.Gui, "AbsoluteSize" },
        { self.UIScale, "Scale" },
    } do
        table.insert(p.RepositionConnections,
            spec[1]:GetPropertyChangedSignal(spec[2]):Connect(reposition))
    end
    table.insert(p.RepositionConnections, anchor.Destroying:Connect(function()
        if self._popup == p then self:_closePopup() end
    end))
    self:PlayUISound("DropdownOpen")
    self:_placePopup(p, true)
end

function Hub:_closePopup()
	local p = self._popup
	if not p then
		return
	end
	self._popup = nil
	self:_overlayUnregister("Popup", p.Holder)
	Motion.cancel(self, "popup-position")
	if not self._destroyed then self:PlayUISound("DropdownClose") end
	self._popupJustClosed = true
	task.defer(function()
		self._popupJustClosed = false
	end)
    for _, connection in p.RepositionConnections or {} do
        connection:Disconnect()
    end
    if p.ShieldConnection then p.ShieldConnection:Disconnect() end
    if p.Shield and p.Shield.Parent then p.Shield:Destroy() end
	if p.OnClose then p.OnClose() end
	p.Holder:Destroy()
end

function Hub:Prompt(o)
	if self._destroyed then return nil end
	local prompt = dialog(self.Gui, self.Theme, o)
	local layer = prompt.Layer
	local function remove()
		self:_overlayUnregister("Prompt", prompt)
	end
	prompt.OnClosed = remove
	self:_overlayRegister("Prompt", prompt, {
		Content = layer:FindFirstChild("Holder"),
		Modal = true, Outside = false,
		Close = function() prompt.Close() end,
	})
	self:_connect(layer.Destroying, remove)
	return prompt
end

------ notifications: a slit that opens
--[[
	A notification starts as a thin vertical slit at the screen edge. The card opens out of
	it, the slit drains as the timer, and when it is empty the card closes back into the slit
	and the stack folds up. Hovering pauses the timer; clicking dismisses.
]]
function Hub:Notify(options)
	if self._destroyed then return end
	options = type(options) == "table" and options or { Title = tostring(options) }
	local theme = self.Theme
	local duration = options.Duration or 4
	local width = math.min(300, math.max(160, viewport().X / self._scale - 28))
	self._toastOrder = (self._toastOrder or 0) - 1
	local holder = create("Frame", {
		Name = "Toast",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(width, 0),
		LayoutOrder = self._toastOrder,
		Parent = self.Toasts,
	})
	local clip = create("Frame", {
		Name = "Clip",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		ClipsDescendants = true,
		Parent = holder,
	})
	local card = create("TextButton", {
		Name = "Card",
		BackgroundColor3 = themeColor(theme, "Panel"),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -1, 0, 1),
		Size = UDim2.new(0, width - 8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		AutoButtonColor = false,
		Parent = clip,
	}, { corner(4), stroke(themeColor(theme, "PanelStroke")), padding(9, 14, 10, 12), list(Enum.FillDirection.Vertical, 3) })
	local titleRow = create("Frame", { Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Parent = card }, {
		list(Enum.FillDirection.Horizontal, 7, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
	})
	local icon = options.Icon and iconLabel(options.Icon, 14, theme.Text)
	if icon then
		icon.Parent = titleRow
	end
	text({ Parent = titleRow, Text = options.Title or self.Name, FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 13, Size = UDim2.new(1, icon and -21 or 0, 0, 16), LayoutOrder = 2, TextTruncate = Enum.TextTruncate.AtEnd })
	if options.Content and options.Content ~= "" then
		text({
			Parent = card,
			Text = options.Content,
			TextSize = 12,
			TextColor3 = themeColor(theme, "SubText"),
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
		})
	end
	local slit = create("Frame", {
		Name = "Slit",
		BackgroundColor3 = options.Tone or themeColor(theme, "Accent"),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 2, 0, 0),
		BorderSizePixel = 0,
		Parent = holder,
	}, { corner(1) })

	local closing = false
	local targetHeight, targetWidth = 0, 0
	local function fitToast()
		if self._destroyed or not holder.Parent or closing then return end
		local nextWidth = math.min(300, math.max(160, viewport().X / self._scale - 28))
		if nextWidth ~= width then
			width = nextWidth
			card.Size = UDim2.new(0, width - 8, 0, 0)
		end
		local h = math.max(37, math.ceil(card.AbsoluteSize.Y / self._scale) + 2)
		if h == targetHeight and width == targetWidth then return end
		targetHeight, targetWidth = h, width
		tween(holder, SETTLE, { Size = UDim2.fromOffset(width, h) })
	end
	-- Wrapped text and late font/layout updates can change AutomaticSize after creation.
	local sizeConn = card:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToast)
	local viewportConn = self.Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToast)
	local scaleConn = self.UIScale:GetPropertyChangedSignal("Scale"):Connect(fitToast)
	holder.Destroying:Connect(function()
		sizeConn:Disconnect()
		viewportConn:Disconnect()
		scaleConn:Disconnect()
	end)
	-- 1) the stack makes room, 2) the slit draws, 3) the card opens out of it
	fitToast()
	local draw = tween(slit, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 2, 1, -6) })
	draw.Completed:Wait()
	if not holder.Parent then
		return
	end
	tween(clip, RISE, { Size = UDim2.new(1, -6, 1, 0) })

	local function close()
		if closing then
			return
		end
		closing = true
		tween(clip, FOLD, { Size = UDim2.new(0, 0, 1, 0) }).Completed:Wait()
		tween(slit, FOLD, { Size = UDim2.new(0, 2, 0, 0) }).Completed:Wait()
		tween(holder, FOLD, { Size = UDim2.fromOffset(width, 0) }).Completed:Wait()
		holder:Destroy()
	end
	-- the slit is the timer
	local timer = TweenService:Create(slit, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 2, 0, 0) })
	timer.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed then
			task.spawn(close)
		end
	end)
	task.delay(0.3, function()
		if not closing then
			timer:Play()
		end
	end)
	card.MouseEnter:Connect(function()
		if not closing then
			timer:Pause()
		end
	end)
	card.MouseLeave:Connect(function()
		if not closing then
			timer:Play()
		end
	end)
	card.MouseButton1Click:Connect(function()
		timer:Pause()
		task.spawn(close)
	end)
end

---------------------------------------------------------------- stealth
function Hub:SetStealth(on: boolean)
	on = on == true
	self.Stealth = on
	secureHubs[self] = on and true or nil
	queueSecureFont()
	if on then
		-- Inspect live instances too; startup mode is needed to avoid earlier loads.
		for _, hub in RiftUI.Hubs do
			for _, inst in hub.Gui:GetDescendants() do
				watchAsset(inst)
				if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then inst.Image = secureProperty("Image", inst.Image) end
				if inst:IsA("ImageButton") then inst.HoverImage = secureProperty("HoverImage", inst.HoverImage) inst.PressedImage = secureProperty("PressedImage", inst.PressedImage) end
				if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then inst.FontFace = secureProperty("FontFace", inst.FontFace) end
			end
		end
	end
	if self._stealthControl then self._stealthControl:Set(on, true) end
	if self._stealthStatus then self._stealthStatus:Set(on and "Script: On" or "Script: Off") end
end

---------------------------------------------------------------- tabs
local Tab = {}
Tab.__index = Tab

-- SPDX-License-Identifier: MPL-2.0
-- Real first-level Dock grouping. Each group owns a horizontal layout container;
-- separators belong to the Dock rather than masquerading as tabs.
local DockTabGroup = {}
DockTabGroup.__index = DockTabGroup

function DockTabGroup:Tab(options)
    options = type(options) == "table" and table.clone(options) or { Name = tostring(options) }
    options.Group = self.Name
    return self.Hub:Tab(options)
end

function DockTabGroup:SetOrder(order)
    assert(type(order) == "number", "TabGroup order must be a number")
    self.Order = order
    self.Frame.LayoutOrder = order
    if self.Separator then self.Separator.LayoutOrder = order - 1 end
end

function Hub:TabGroup(options)
    options = type(options) == "table" and options or { Name = tostring(options) }
    local name = options.Name
    assert(type(name) == "string" and name ~= "", "TabGroup requires a non-empty Name")
    self.DockGroups = self.DockGroups or {}
    local existing = self.DockGroups[name]
    if existing then
        assert(existing.Hub == self, "TabGroup belongs to another hub")
        return existing
    end
    local order = options.Order
    if order == nil then
        self._nextDockGroupOrder = (self._nextDockGroupOrder or 0) + 1
        order = self._nextDockGroupOrder * 100
    end
    assert(type(order) == "number", "TabGroup Order must be a number")
    local frame = create("Frame", {
        Name = "DockGroup_" .. name,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 40),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = order,
        ClipsDescendants = false,
        ZIndex = 3,
        Parent = self.Dock,
    }, { list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
    local group = setmetatable({
        Hub = self, Name = name, Order = order, Frame = frame, Tabs = {},
        _internal = options._internal == true,
    }, DockTabGroup)
    if options.Separator == true then
        group.Separator = create("Frame", {
            Name = "DockGroupSeparator_" .. name,
            BackgroundColor3 = themeColor(self.Theme, "TileStroke"),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(1, 24),
            LayoutOrder = order - 1,
            Parent = self.Dock,
        })
    end
    self.DockGroups[name] = group
    if not group._internal then
        self:_record(self, "TabGroup", {
            Name = name, Order = order, Separator = options.Separator == true,
        }, group)
    end
    return group
end


function Hub:Tab(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local group = options.Group
	if type(group) == "string" then
		group = self.DockGroups[group] or self:TabGroup({ Name = group })
	elseif group == nil then
		group = self.DefaultTabGroup
	end
	assert(type(group) == "table" and group.Hub == self and group.Frame ~= nil,
		"Tab Group must belong to the current hub")
	local theme = self.Theme
	local tab = setmetatable({
		Hub = self,
		Name = options.Name or "Tab",
		Group = group,
		SubTabs = {},
		ActiveSubTab = nil,
		Description = options.Description,
		Icon = options.Icon,
		Sections = {},
		Requires = requirementIds(options.Requires),
		_internal = options._internal,
		_count = 0,
	}, Tab)
	local order = options._order or (#group.Tabs + 1)

	local tile = create("TextButton", {
		Name = "Tile_" .. tab.Name,
		BackgroundColor3 = themeColor(theme, "TileActive"),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(40, 40),
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
		Parent = group.Frame,
	}, { corner(9) })
	local tileStroke = stroke(themeColor(theme, "TileActiveStroke"), 1, 1)
	tileStroke.Parent = tile
	local press = create("UIScale", { Name = "Press", Scale = 1, Parent = tile })
	tab.Tile = tile
	tab.TileStroke = tileStroke
	local icon = iconLabel(tab.Icon, 19, theme.SubText, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = tile,
	})
	tab.TileIcon = icon
	if not icon then
		text({
			Parent = tile,
			Text = string.upper(string.sub(tab.Name, 1, 1)),
			TextSize = 16,
			FontFace = inter(Enum.FontWeight.SemiBold),
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end
	tab.Indicator = create("Frame", {
		Name = "Active",
		BackgroundColor3 = themeColor(theme, "Text"),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 2),
		Size = UDim2.fromOffset(0, 2),
		BackgroundTransparency = 1,
		Parent = tile,
	}, { corner(1) })
	tab.Badge = create("Frame", {
		Name = "Badge",
		BackgroundColor3 = themeColor(theme, "Accent"),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 1, 0, -1),
		Size = UDim2.fromOffset(13, 13),
		Visible = false,
		ZIndex = 3,
		Parent = tile,
	}, { corner(7), stroke(themeColor(theme, "Panel"), 2) })
	tab.BadgeText = text({
		Parent = tab.Badge,
		AnchorPoint = Vector2.new(0.5, 0.5),
		-- At 9px Inter's digit ink sits slightly above/left of its line box centre.
		Position = UDim2.new(0.5, 0.5, 0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		TextSize = 9,
		FontFace = inter(Enum.FontWeight.Bold),
		TextColor3 = themeColor(theme, "AccentText"),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 4,
	})

	self:_connect(tab.BadgeText:GetPropertyChangedSignal("TextBounds"), function()
		tab.Badge.Size = UDim2.fromOffset(math.max(13, math.ceil(tab.BadgeText.TextBounds.X / self._scale) + 6), 13)
	end)

	self:_connect(tile.MouseEnter, function()
		if self._open ~= tab then
			tween(tile, FAST, { BackgroundColor3 = themeColor(theme, "TileHover"), BackgroundTransparency = 0 })
			if icon then
				tween(icon, FAST, { ImageColor3 = themeColor(theme, "Text") })
			end
		end
		self.TooltipText.Text = tab.Name
		local s = self._scale
		local tp, ts = tile.AbsolutePosition, tile.AbsoluteSize
		local dock = self.Dock
		self.Tooltip.Position = UDim2.fromOffset((tp.X + ts.X / 2) / s, (dock.AbsolutePosition.Y + dock.AbsoluteSize.Y + 6) / s)
		self.Tooltip.Visible = self._visible
	end)
	self:_connect(tile.MouseLeave, function()
		if self._open ~= tab then
			tween(tile, FAST, { BackgroundTransparency = 1 })
			if icon then
				tween(icon, FAST, { ImageColor3 = themeColor(theme, "SubText") })
			end
		end
		if self.TooltipText.Text == tab.Name then
			self.Tooltip.Visible = false
		end
		tween(press, FAST, { Scale = 1 })
	end)
	self:_connect(tile.MouseButton1Down, function()
		-- A secondary rail is anchored to this tile: do not scale its parent.
		if #tab.SubTabs > 0 then
			if press.Scale ~= 1 then cancelMotion(press); press.Scale = 1 end
		else
			tween(press, FAST, { Scale = 0.92 })
		end
	end)
	self:_connect(tile.MouseButton1Up, function()
		if #tab.SubTabs > 0 then
			cancelMotion(press)
			press.Scale = 1
		else
			tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		end
	end)
	self:_connect(tile.MouseButton1Click, function()
		if self._open == tab then
			if tab.SubTabs and #tab.SubTabs > 0 then
				self:_toggleSubTabs(tab)
			else
				self:Close()
			end
		else
			self:Open(tab)
		end
	end)

	local page = create("Frame", {
		Name = "Page_" .. tab.Name,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self.Pages,
	})
	local scroll = create("ScrollingFrame", {
		Name = "Scroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		-- Keep a fixed six-pixel edge below the header while scrolling.
		Position = UDim2.fromOffset(0, 6),
		Size = UDim2.new(1, 0, 1, -6),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = themeColor(theme, "Knob"),
		ScrollBarImageTransparency = 0.4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = page,
	})
	local columns = create("Frame", {
		Name = "Columns",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = scroll,
	}, { padding(4, 16, 12, 16) })
	local function column(side: number)
		return create("Frame", {
			Name = side == 0 and "Left" or "Right",
			BackgroundTransparency = 1,
			Position = UDim2.new(side * 0.5, side == 0 and 0 or 9, 0, 0),
			Size = UDim2.new(0.5, -9, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = columns,
		}, { list(Enum.FillDirection.Vertical, 10) })
	end
	tab.Page = page
	tab.Scroll = scroll
	tab.Columns = { column(0), column(1), Frame = columns }
	self:_connect(columns:GetPropertyChangedSignal("AbsoluteSize"), function()
		if self._open == tab then self:_fitPanel(tab, false) end
	end)

	table.insert(self.Tabs, tab)
	table.insert(group.Tabs, tab)
	local recordOptions = table.clone(options)
	recordOptions.Group = group.Name
	self:_record(self, "Tab", recordOptions, tab)
	return tab
end

do
-- SPDX-License-Identifier: MPL-2.0
-- Animated two-level navigation anchored to the active primary Dock icon.
-- SubTab objects use Tab's existing Section/controls implementation.
local SUBTAB_TILE = 32
local SUBTAB_STEP = 38
local SUBTAB_GAP = 3
local SUBTAB_RISE = 7
local SUBTAB_APPEAR = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SUBTAB_DISMISS = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local SUBTAB_SELECT = TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function Hub:_contentTab(tab)
    return tab and (tab.ActiveSubTab or tab) or nil
end

function Hub:_updateTabHeader(tab)
    local current = self:_contentTab(tab)
    local caption = current and current.IsSubTab and current.Name
        or (tab and tab.Description) or ""
    self.HeaderSub.Text = caption
    self.HeaderSub.Visible = not self.Search.Visible and caption ~= ""
    self.HeaderTitle.Position = UDim2.fromOffset(44, caption ~= "" and 12 or 20)
end

function Hub:_setSubTab(tab, sub)
    if self._destroyed or not tab or tab.IsSubTab then return false end
    if sub and sub.ParentTab ~= tab then return false end
    local old = self:_contentTab(tab)
    tab.ActiveSubTab = sub
    local nextPage = self:_contentTab(tab)
    if old and old ~= nextPage then old.Page.Visible = false end
    tab.Page.Visible = self._open == tab and sub == nil
    local animate = self._subTabRailVisible and self._subTabParent == tab
    for _, item in tab.SubTabs or {} do
        item.Page.Visible = self._open == tab and item == sub
        if item.Tile then
            local selected = item == sub
            local background = selected and 0 or 1
            local foreground = selected and self.Theme.Text or self.Theme.SubText
            if animate then
                tween(item.Tile, SUBTAB_SELECT, { BackgroundTransparency = background })
                if item.TileIcon then
                    tween(item.TileIcon, SUBTAB_SELECT, { ImageColor3 = foreground })
                elseif item.TileText then
                    tween(item.TileText, SUBTAB_SELECT, { TextColor3 = foreground })
                end
            else
                item.Tile.BackgroundTransparency = background
                if item.TileIcon then item.TileIcon.ImageColor3 = foreground end
                if item.TileText then item.TileText.TextColor3 = foreground end
            end
        end
    end
    if tab._allSubTile then
        local selected = sub == nil
        if animate then
            tween(tab._allSubTile, SUBTAB_SELECT, { BackgroundTransparency = selected and 0 or 1 })
        else
            tab._allSubTile.BackgroundTransparency = selected and 0 or 1
        end
    end
    if self._open == tab then
        self:_updateTabHeader(tab)
        if old ~= nextPage then nextPage.Scroll.CanvasPosition = Vector2.zero end
        self:_fitPanel(tab, false)
        if old ~= nextPage then self:_requestPanelFit() end
    end
    return true
end

function Hub:_closeSubTabs()
    if not self._subTabRailVisible then return end
    self:_overlayUnregister("SubTabs", self._subTabRail)
    self._subTabRailVisible = false
    self._subTabParent = nil
    if self._subTabPointerShield then self._subTabPointerShield.Visible = false end
    self._subTabMotionId = (self._subTabMotionId or 0) + 1
    local motionId = self._subTabMotionId
    local rail, frost, veil = self._subTabRail, self._subTabFrost, self._subTabVeil
    if not rail or not frost then return end
    self.Tooltip.Visible = false
    frost.Active = false
    self._subTabAnimating = true
    local target = self._subTabTarget or rail.Position
    local steps = {
        { Target = rail, Goals = {
            GroupTransparency = 1,
            Position = target + UDim2.fromOffset(0, SUBTAB_RISE),
        } },
        { Target = frost, Goals = { BackgroundTransparency = 1 } },
    }
    if veil then table.insert(steps, { Target = veil, Goals = { BackgroundTransparency = 1 } }) end
    Motion.transition(self, "subtab-rail", "closed", steps, SUBTAB_DISMISS, function()
        if self._destroyed or self._subTabMotionId ~= motionId then return end
        rail.Visible = false
        frost.Visible = false
        self._subTabAnimating = false
        if self.DockHolder and self._subTabDockZIndex ~= nil then
            self.DockHolder.ZIndex = self._subTabDockZIndex
        end
    end)
end

function Hub:_positionSubTabs()
    local tab, rail = self._subTabParent, self._subTabRail
    if not self._subTabRailVisible or not tab or not rail or not tab.Tile.Parent then return end

    -- Position is relative to the selected 40px primary tile, not the
    -- full ScreenGui/Dock. This survives screen insets, scaling and movement.
    local scale = math.max(self.UIScale.Scale, 0.01)
    local count = #tab.SubTabs + ((#tab.Sections > 0) and 1 or 0)
    local natural = 10 + count * SUBTAB_STEP
    local width = math.min(natural, math.max(48, self.Dock.AbsoluteSize.X / scale - 14))
    local tileSize = tab.Tile.AbsoluteSize
    local view = viewport().X
    local centerPhysical = tab.Tile.AbsolutePosition.X + tileSize.X * .5
    local leftEdge = centerPhysical - width * scale * .5
    local rightEdge = centerPhysical + width * scale * .5
    local shift = 0
    if leftEdge < 6 then shift = (6 - leftEdge) / scale end
    if rightEdge > view - 6 then shift = (view - 6 - rightEdge) / scale end

    -- Rail AnchorPoint=(0.5,1). Bottom is always 3px above tile's top.
    -- No late absolute-position correction can snap the finished tween.
    local target = UDim2.new(.5, math.floor(shift + .5), 0, -SUBTAB_GAP)
    self._subTabTarget = target
    rail.Size = UDim2.fromOffset(width, 40)
    self._subTabScroll.CanvasSize = UDim2.fromOffset(natural, 0)
    if not self._subTabAnimating then rail.Position = target end
end

function Hub:_ensureSubTabUI()
    if self._subTabRail then return end
    local theme = self.Theme
    local frost = create("TextButton", {
        Name = "SubTabPanelFrost", Text = "", AutoButtonColor = false,
        BackgroundColor3 = themeColor(theme, "Panel"),
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 25,
        Visible = false, Parent = self.PanelHolder,
    }, { corner(14) })
    -- UI-only scrim, rather than a global Lighting blur affecting the game.
    local veil = create("Frame", {
        Name = "SubTabFrostVeil", BackgroundColor3 = themeColor(theme, "Scrim"),
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        ZIndex = 26, Parent = frost,
    }, { corner(14) })
    self:_connect(frost.MouseButton1Click, function() self:_closeSubTabs() end)
    self._subTabFrost, self._subTabVeil = frost, veil

    -- Consume native GUI clicks on the panel while the second-level row
    -- floats above it. Global InputBegan alone cannot block a lower button's
    -- MouseButton1Click. Dock tiles stay tappable at ZIndex 40+.
    local pointerShield = create("TextButton", {
        Name = "SubTabPointerShield", Text = "", AutoButtonColor = false,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Active = true, Visible = false,
        Size = UDim2.fromScale(1, 1), ZIndex = 38, Parent = self.Gui,
    })
    self._subTabPointerShield = pointerShield
    self:_connect(pointerShield.MouseButton1Click, function()
        local top = self:_overlayTop()
        if self._subTabRailVisible and top and top.Kind == "SubTabs" then
            self:_closeSubTabs()
        end
    end)

    -- CanvasGroup opacity composites the icon row; the glyphs never scale.
    local rail = create("CanvasGroup", {
        Name = "SubTabRail", BackgroundColor3 = themeColor(theme, "Panel"),
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.fromOffset(160, 40),
        Position = UDim2.fromOffset(0, 0),
        GroupTransparency = 1,
        ZIndex = 42, Visible = false, Parent = self.DockHolder,
    }, { corner(10), stroke(themeColor(theme, "PanelStroke"), 1) })
    local scroll = create("ScrollingFrame", {
        Name = "SubTabItems", BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(5, 4),
        Size = UDim2.new(1, -10, 1, -8),
        ZIndex = 43, Parent = rail,
    }, { list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
    self._subTabRail, self._subTabScroll = rail, scroll
    self._subTabStorage = Instance.new("Folder")
    self._subTabStorage.Name = "SubTabStorage"
    self._subTabStorage.Parent = self.Gui
    self:_connect(self.Dock:GetPropertyChangedSignal("AbsoluteSize"), function()
        if self._subTabRailVisible then self:_positionSubTabs() end
    end)
    self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
        if self._subTabRailVisible then self:_positionSubTabs() end
    end)
end

function Hub:_toggleSubTabs(tab)
    if self._destroyed or self._open ~= tab or #(tab.SubTabs or {}) == 0 then return end
    if self._subTabRailVisible and self._subTabParent == tab then
        self:_closeSubTabs()
        return
    end
    self:_closeSubTabs()
    self:_ensureSubTabUI()
    for _, tile in self._subTabScroll:GetChildren() do
        if tile:IsA("TextButton") then tile.Parent = self._subTabStorage end
    end
    if #tab.Sections > 0 then
        if not tab._allSubTile then
            local all = create("TextButton", {
                Name = "All", Text = "All", TextSize = 10,
                FontFace = inter(Enum.FontWeight.Medium),
                TextColor3 = themeColor(self.Theme, "Text"),
                BackgroundColor3 = themeColor(self.Theme, "TileActive"),
                AutoButtonColor = false,
                Size = UDim2.fromOffset(SUBTAB_TILE, SUBTAB_TILE),
                ZIndex = 44, Parent = self._subTabStorage,
            }, { corner(8) })
            tab._allSubTile = all
            self:_connect(all.MouseButton1Click, function() self:_setSubTab(tab, nil) end)
        end
        tab._allSubTile.Parent = self._subTabScroll
    end
    for _, child in tab.SubTabs do child.Tile.Parent = self._subTabScroll end
    -- Reopening a closing rail on the same tile continues from its current
    -- opacity/position instead of teleporting back to the animation origin.
    local resuming = self._subTabRail.Visible and self._subTabRail.Parent == tab.Tile
    Motion.cancel(self, "subtab-rail")
    -- The primary tile is the anchor, not DockHolder.
    self._subTabRail.Parent = tab.Tile
    local press = tab.Tile:FindFirstChild("Press")
    if press and press:IsA("UIScale") then cancelMotion(press); press.Scale = 1 end
    self._subTabParent = tab
    self._subTabRailVisible = true
    self:_overlayRegister("SubTabs", self._subTabRail, {
        Content = self._subTabRail, Anchor = tab.Tile,
        Close = function() self:_closeSubTabs() end,
    })
    self._subTabMotionId = (self._subTabMotionId or 0) + 1
    local motionId = self._subTabMotionId
    local rail, frost, veil = self._subTabRail, self._subTabFrost, self._subTabVeil
    self._subTabAnimating = true
    if self._subTabDockZIndex == nil then
        self._subTabDockZIndex = self.DockHolder.ZIndex
    end
    -- Sibling ZIndex mode: raise the owner so the rail appears above the panel.
    self.DockHolder.ZIndex = 40
    self._subTabPointerShield.Visible = true
    rail.Visible = true
    frost.Visible = true
    frost.Active = true
    self.Tooltip.Visible = false
    self:_positionSubTabs()
    local target = self._subTabTarget
    -- A seven-pixel rise and quintic fade, without resizing glyphs or the main panel.
    if not resuming then
        rail.Position = target + UDim2.fromOffset(0, SUBTAB_RISE)
        rail.GroupTransparency = 1
        frost.BackgroundTransparency = 1
        veil.BackgroundTransparency = 1
    end
    self:_setSubTab(tab, tab.ActiveSubTab)
    Motion.transition(self, "subtab-rail", "open", {
        { Target = rail, Goals = { GroupTransparency = 0, Position = target } },
        { Target = frost, Goals = { BackgroundTransparency = 0.37 } },
        { Target = veil, Goals = { BackgroundTransparency = 0.66 } },
    }, SUBTAB_APPEAR, function()
        if self._destroyed or self._subTabMotionId ~= motionId then return end
        self._subTabAnimating = false
        -- No post-animation geometry correction or glyph scaling.
    end)
end

function Tab:SubTab(options)
    assert(not self.IsSubTab, "SubTab only supports two navigation levels")
    options = type(options) == "table" and options or { Name = tostring(options) }
    local hub = self.Hub
    local theme = hub.Theme
    self.SubTabs = self.SubTabs or {}
    local name = options.Name or ("SubTab " .. tostring(#self.SubTabs + 1))
    for _, existing in self.SubTabs do
        assert(existing.Name ~= name, "duplicate SubTab name: " .. tostring(name))
    end
    hub:_ensureSubTabUI()
    local child = setmetatable({
        Hub = hub, ParentTab = self, IsSubTab = true,
        Name = name, Description = options.Description, Icon = options.Icon,
        Sections = {}, Requires = mergedRequirements(self.Requires, options.Requires),
        _internal = options._internal or self._internal,
        _count = 0,
    }, Tab)

    local tile = create("TextButton", {
        Name = "SubTile_" .. name,
        Text = "", AutoButtonColor = false,
        BackgroundColor3 = themeColor(theme, "TileActive"),
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(SUBTAB_TILE, SUBTAB_TILE),
        LayoutOrder = #self.SubTabs + 1,
        ZIndex = 44, Parent = hub._subTabStorage,
    }, { corner(8) })
    child.Tile = tile
    child.TileIcon = iconLabel(child.Icon, 16, theme.SubText, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ZIndex = 45, Parent = tile,
    })
    if not child.TileIcon then
        child.TileText = text({
            Parent = tile, Text = string.sub(name, 1, 2),
            TextSize = 12, TextColor3 = theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.fromScale(1, 1), ZIndex = 45,
        })
    end
    hub:_connect(tile.MouseButton1Click, function()
        -- Selecting a child does not dismiss the secondary rail.
        hub:_setSubTab(self, child)
    end)
    local page = create("Frame", {
        Name = "SubPage_" .. name, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), Visible = false, Parent = hub.Pages,
    })
    local scroll = create("ScrollingFrame", {
        Name = "Scroll", BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        ScrollBarImageTransparency = .4,
        ScrollingDirection = Enum.ScrollingDirection.Y, Parent = page,
    })
    local columns = create("Frame", {
        Name = "Columns", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = scroll,
    }, { padding(10, 16, 12, 16) })
    local function column(side)
        return create("Frame", {
            Name = side == 0 and "Left" or "Right",
            BackgroundTransparency = 1,
            Position = UDim2.new(side * .5, side == 0 and 0 or 9, 0, 0),
            Size = UDim2.new(.5, -9, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = columns,
        }, { list(Enum.FillDirection.Vertical, 10) })
    end
    child.Page, child.Scroll = page, scroll
    child.Columns = { column(0), column(1), Frame = columns }
    hub:_connect(columns:GetPropertyChangedSignal("AbsoluteSize"), function()
        if hub._open == self and self.ActiveSubTab == child then
            hub:_requestPanelFit()
        end
    end)
    table.insert(self.SubTabs, child)
    if not self.ActiveSubTab then self.ActiveSubTab = child end
    if hub._open == self then hub:_setSubTab(self, self.ActiveSubTab) end
    if not self._subTabLayoutConn then
        self._subTabLayoutConn = hub:_connect(self.Tile:GetPropertyChangedSignal("AbsolutePosition"), function()
            if hub._subTabRailVisible and hub._subTabParent == self then hub:_positionSubTabs() end
        end)
    end
    hub:_record(self, "SubTab", options, child)
    return child
end

end

function Tab:_setActive(active: boolean)
	local theme = self.Hub.Theme
	tween(self.Tile, FAST, { BackgroundColor3 = themeColor(theme, "TileActive"), BackgroundTransparency = active and 0 or 1 })
	tween(self.TileStroke, FAST, { Transparency = active and 0 or 1 })
	if self.TileIcon then
		tween(self.TileIcon, FAST, { ImageColor3 = active and themeColor(theme, "Text") or themeColor(theme, "SubText") })
	end
	tween(self.Indicator, SETTLE, {
		Size = UDim2.fromOffset(active and 12 or 0, 2),
		BackgroundTransparency = active and 0 or 1,
	})
end

function Tab:_recount()
	local n = 0
	for _, s in self.Sections do
		for _, c in s.Controls do
			if c.Type == "Toggle" and c.Value == true and not c._internal then
				n += 1
			end
		end
	end
	self._count = n
	if self.IsSubTab then return end -- secondary entries do not own primary badges
	-- Counting enabled toggles is opt-in (CreateHub{ ToggleBadges = true }); unexplained
	-- numbers on the toolbar read as notifications.
	if self._badge == nil and self.Hub.Options.ToggleBadges then
		self.Badge.Visible = n > 0
		self.BadgeText.Text = tostring(n)
	end
end

-- Shows a small count or word on the toolbar tile, e.g. Tab:SetBadge(3) or Tab:SetBadge("New").
-- nil or 0 hides it.
function Tab:SetBadge(value)
	if self.IsSubTab then self._badge = value; return end
	if value == 0 or value == "" then
		value = nil
	end
	self._badge = value
	self.Badge.Visible = value ~= nil
	self.BadgeText.Text = value ~= nil and tostring(value) or ""
	if value == nil then
		self:_recount()
	end
end

---------------------------------------------------------------- sections
local Section = {}
Section.__index = Section

function Tab:Section(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local hub = self.Hub
	local theme = hub.Theme
	local side = options.Side
	if side == "Right" then
		side = 1
	elseif side == "Left" then
		side = 0
	else
		local left, right = 0, 0
		for _, s in self.Sections do
			if s.Side == 0 then
				left += 1
			else
				right += 1
			end
		end
		side = left <= right and 0 or 1
	end
	local section = setmetatable({
		Tab = self,
		Hub = hub,
		Name = options.Name or "Section",
		Side = side,
		Controls = {},
		Requires = mergedRequirements(self.Requires, options.Requires),
		Pinned = false,
		_internal = self._internal,
		_order = 0,
	}, Section)
	section.Id = (self.ParentTab and (self.ParentTab.Name .. "/" .. self.Name) or self.Name) .. "/" .. section.Name

	local frame = create("Frame", {
		Name = "Section_" .. section.Name,
		BackgroundColor3 = themeColor(theme, "Section"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self.Sections + 1,
		Parent = self.Columns[side + 1],
	}, { padding(0, 2, 6, 2), list(Enum.FillDirection.Vertical, 0) })
	frame.BackgroundTransparency = 1
	local head = create("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = frame })
	-- the group title sits on a hairline that runs from the title to the pin, like an imgui groupbox
	local pinRoom = options.Pinnable == false and 0 or 24
	local rule = create("Frame", {
		Name = "Rule",
		BackgroundColor3 = themeColor(theme, "Divider"),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, -pinRoom, 0, 1),
		Parent = head,
	})
	-- Collapsible by default; the user's choice per section outlives the session.
	local collapsible = options.Collapsible ~= false
	local remembered = hub.SetupData and type(hub.SetupData.Collapsed) == "table" and hub.SetupData.Collapsed[section.Id]
	section._collapsible = collapsible
	section._collapsed = collapsible and (remembered == true or (remembered == nil and options.Collapsed == true))
	local titleChip = create("Frame", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 2,
		Parent = head,
	}, {
		padding(0, 8, 0, 0),
		create("UISizeConstraint", { MaxSize = Vector2.new(196, 26) }),
		list(Enum.FillDirection.Horizontal, 3, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
	})
	if collapsible then
		section._chevron = iconLabel("chevron-down", 12, theme.Muted, { Rotation = section._collapsed and -90 or 0, ZIndex = 3, Parent = titleChip })
	end
	section._titleLabel = text({
		Parent = titleChip,
		LayoutOrder = 1,
		Text = string.upper(section.Name),
		TextSize = 11,
		FontFace = inter(Enum.FontWeight.SemiBold),
		TextColor3 = themeColor(theme, "SubText"),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
	})
	local function placeRule()
		local w = titleChip.AbsoluteSize.X / hub._scale
		rule.Position = UDim2.new(0, w, 0.5, 0)
		rule.Size = UDim2.new(1, -w - pinRoom, 0, 1)
	end
	hub:_connect(titleChip:GetPropertyChangedSignal("AbsoluteSize"), placeRule)
	placeRule()
	if collapsible then
		local toggle = create("TextButton", { Name = "Collapse", BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.new(1, -pinRoom, 1, 0), ZIndex = 4, Parent = head })
		hub:_connect(toggle.MouseButton1Click, function() section:SetCollapsed(not section._collapsed) end)
		hub:_connect(toggle.MouseEnter, function()
			setThemed(section._titleLabel, "TextColor3", themeColor(theme, "Text"))
			if section._chevron then setThemed(section._chevron, "ImageColor3", themeColor(theme, "SubText")) end
		end)
		hub:_connect(toggle.MouseLeave, function()
			setThemed(section._titleLabel, "TextColor3", themeColor(theme, "SubText"))
			if section._chevron then setThemed(section._chevron, "ImageColor3", themeColor(theme, "Muted")) end
		end)
	end
	if options.Pinnable ~= false then
		local pin = create("TextButton", {
			Name = "Pin",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 4, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			Text = "",
			AutoButtonColor = false,
			Parent = head,
		})
		local pinIcon = iconLabel("pin", 13, theme.Muted, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = pin })
		if not pinIcon then
			text({ Parent = pin, Text = "Pin", TextSize = 10, TextColor3 = themeColor(theme, "Muted"), Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
		end
		hub:_connect(pin.MouseEnter, function()
			if pinIcon then
				setThemed(pinIcon, "ImageColor3", themeColor(theme, "Text"))
			end
		end)
		hub:_connect(pin.MouseLeave, function()
			if pinIcon then
				setThemed(pinIcon, "ImageColor3", themeColor(theme, "Muted"))
			end
		end)
		hub:_connect(pin.MouseButton1Click, function()
			section:Pin()
		end)
	end
	-- Rows sit in a clip that folds to the header when the section collapses.
	local clip = create("Frame", {
		Name = "RowsClip",
		BackgroundTransparency = 1,
		Visible = not section._collapsed,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = section._collapsed and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = frame,
	})
	local rows = create("Frame", {
		Name = "Rows",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = clip,
	}, { list(Enum.FillDirection.Vertical, 0), padding(0, 1) })
	section._rowsClip = clip
	section.Frame = frame
	section.Head = head
	section.Rows = rows
	hub:_connect(frame.Destroying, function()
		local key = "section-collapse:" .. section.Id
		Motion.cancel(hub, key)
		Motion.cancel(hub, key .. ":chevron")
	end)

	table.insert(self.Sections, section)
	hub:_record(self, "Section", options, section)
	return section
end

-- Fold the rows to the header, or open them. Search results peek inside collapsed sections
-- without changing the saved choice.
function Section:_applyCollapse(animate: boolean)
	local clip = self._rowsClip
	if not clip then return end
	local hub = self.Hub
	local key = "section-collapse:" .. self.Id
	local shut = self._collapsed and not self._peek
	if self._chevron then
		Motion.play(hub, key .. ":chevron", self._chevron,
			{ Rotation = shut and -90 or 0 }, FAST)
	end
	local function settle()
		clip.AutomaticSize = shut and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
		clip.Size = UDim2.new(1, 0, 0, 0)
		clip.Visible = not shut
	end
	if not animate then
		Motion.cancel(hub, key)
		settle()
		return
	end
	-- Frame clipping keeps live text in the native renderer. Hide the rows
	-- before closing so partly cropped switches cannot flash at the fold edge.
	-- On opening, show them as the clip expands (without texture downsampling).
	local scale = math.max(hub._scale, .01)
	local from = clip.AbsoluteSize.Y / scale
	clip.AutomaticSize = Enum.AutomaticSize.None
	clip.Size = UDim2.new(1, 0, 0, from)
	clip.Visible = not shut
	Motion.play(hub, key, clip,
		{ Size = UDim2.new(1, 0, 0, shut and 0 or self.Rows.AbsoluteSize.Y / scale) },
		SETTLE, settle)
end

function Section:SetCollapsed(collapsed: boolean, instant: boolean?)
	if not self._collapsible or self._isGroup then return end
	collapsed = collapsed == true
	if self._collapsed == collapsed then return end
	self._collapsed = collapsed
	local hub = self.Hub
	local map = table.clone(hub.SetupData and type(hub.SetupData.Collapsed) == "table" and hub.SetupData.Collapsed or {})
	map[self.Id] = collapsed or nil
	hub:_savePref("Collapsed", map)
	self:_applyCollapse(not instant)
end

function Section:IsCollapsed(): boolean
	return self._collapsed == true
end

function Section:_row(height: number?, name: string?)
	local theme = self.Hub.Theme
	self._order += 1
	local first = #self.Controls == 0
	local row = create("Frame", {
		Name = name or "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height or 34),
		LayoutOrder = self._order,
		Parent = self.Rows,
	})
	create("Frame", {
		Name = "Divider",
		BackgroundColor3 = themeColor(theme, "Divider"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Visible = false,
		Parent = row,
	})
	local _ = first
	return row
end

do
-- SPDX-License-Identifier: MPL-2.0
-- Unified two-state control availability and native, theme-aware action dialogs.
-- MacUI-inspired modal ownership + OasisUI-inspired safe, configurable actions.
-- No CanvasGroup: content and labels render without texture downsampling.
do
    local function actionText(value, fallback)
        return type(value) == "string" and value ~= "" and value or fallback
    end

    function Hub:OpenActionDialog(options)
        if self._destroyed then return nil end
        options = type(options) == "table" and options or {}
        local theme = self.Theme
        local dialogTokens = self.Tokens.Components.Dialog
        local typeTokens = self.Tokens.Typography
        local colors = self.Tokens.Color
        local width = math.clamp(tonumber(options.Width) or dialogTokens.Width,
            dialogTokens.MinWidth, dialogTokens.MaxWidth)
        local availableHeight = math.max(210, viewport().Y / math.max(self._scale or 1, .01)
            - topInset() / math.max(self._scale or 1, .01) - 28)
        local maxDialogHeight = math.min(dialogTokens.MaxHeight, availableHeight)
        local layer = create("TextButton", {
            Name = "ActionDialog", BackgroundColor3 = colors.DialogScrim,
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
            Active = true, Size = UDim2.fromScale(1, 1), ZIndex = 110, Parent = self.Gui,
        })
        local holder = create("Frame", {
            Name = "Holder", BackgroundTransparency = 1, Active = true,
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(.5, 0, .5, 8),
            Size = UDim2.new(1, -dialogTokens.EdgeInset * 2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 111, Parent = layer,
        })
        local sizeLimit = create("UISizeConstraint", {
            MaxSize = Vector2.new(width, maxDialogHeight), Parent = holder,
        })
        shadow(holder, 24, 111, 8)
        local card = create("Frame", {
            Name = "DialogCard", BackgroundColor3 = colors.DialogSurface,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 112, Parent = holder,
        }, { corner(dialogTokens.Radius), stroke(colors.DialogBorder),
            padding(dialogTokens.PaddingY, dialogTokens.PaddingX,
                dialogTokens.PaddingY, dialogTokens.PaddingX),
            list(Enum.FillDirection.Vertical, dialogTokens.Gap) })
        local heading = create("Frame", {
            Name = "Heading", BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, dialogTokens.HeadingHeight), LayoutOrder = 1,
            ZIndex = 113, Parent = card,
        })
        local divider = create("Frame", {
            Name = "HeadingDivider", Parent = heading,
            BackgroundColor3 = colors.BorderSubtle, BackgroundTransparency = .65,
            BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 1), ZIndex = 113,
        })
        local iconPlate = create("Frame", {
            Name = "IconPlate", BackgroundColor3 = colors.DialogIconSurface,
            Size = UDim2.fromOffset(dialogTokens.IconPlateSize, dialogTokens.IconPlateSize),
            ZIndex = 114, Parent = heading,
        }, { corner(dialogTokens.IconPlateRadius) })
        local headingIcon = iconLabel(options.Icon or "lock", dialogTokens.IconSize, colors.DialogIcon, {
            Parent = iconPlate, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 115,
        })
        if not headingIcon then
            text({
                Name = "DialogIconFallback", Parent = iconPlate, Text = "!",
                TextColor3 = colors.DialogIcon, TextSize = dialogTokens.IconSize,
                FontFace = inter(Enum.FontWeight.SemiBold),
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1), ZIndex = 115,
            })
        end
        local titleLabel = text({
            Name = "DialogTitle", Parent = heading,
            Text = actionText(options.Title, "功能暂不可用"),
            FontFace = inter(Enum.FontWeight[typeTokens.DialogTitle.Weight]),
            TextSize = typeTokens.DialogTitle.Size, LineHeight = typeTokens.DialogTitle.LineHeight,
            TextColor3 = colors.DialogTitle,
            Position = UDim2.fromOffset(dialogTokens.IconPlateSize + dialogTokens.TitleGap, dialogTokens.TitleTop),
            Size = UDim2.new(1, -(dialogTokens.IconPlateSize + dialogTokens.TitleGap + dialogTokens.CloseSize + 2), 0,
                dialogTokens.HeadingHeight - dialogTokens.TitleTop),
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 114,
        })
        local closeButton = create("TextButton", {
            Name = "Close", BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, 0, .5, 0),
            Size = UDim2.fromOffset(dialogTokens.CloseSize, dialogTokens.CloseSize), ZIndex = 114, Parent = heading,
        })
        local closeGlyph = iconLabel("x", dialogTokens.CloseIconSize, colors.DialogCloseIcon, {
            Parent = closeButton, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 115,
        })
        if not closeGlyph then
            text({
                Name = "DialogCloseFallback", Parent = closeButton, Text = "×",
                TextColor3 = colors.DialogCloseIcon, TextSize = dialogTokens.CloseIconSize + 2,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1), ZIndex = 115,
            })
        end
        local body = create("ScrollingFrame", {
            Name = "Explanation", BackgroundColor3 = colors.DialogBodySurface,
            BackgroundTransparency = dialogTokens.BodyTransparency, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(), Size = UDim2.new(1, 0, 0, 64),
            LayoutOrder = 2, ZIndex = 113, Parent = card,
        }, { corner(dialogTokens.BodyRadius), padding(dialogTokens.BodyPaddingY,
            dialogTokens.BodyPaddingX, dialogTokens.BodyPaddingY, dialogTokens.BodyPaddingX) })
        local summary = text({
            Name = "Reason", Parent = body,
            Text = actionText(options.Content or options.Reason, "此控件当前已锁定。"),
            TextSize = typeTokens.DialogBody.Size,
            FontFace = inter(Enum.FontWeight[typeTokens.DialogBody.Weight]),
            LineHeight = typeTokens.DialogBody.LineHeight,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
            TextColor3 = colors.DialogBodyText,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 114,
        })
        local details = options.Details
        local description
        if type(details) == "string" and details ~= "" then
            description = text({
                Name = "Details", Parent = body,
                Text = details, TextSize = typeTokens.DialogDetail.Size,
                FontFace = inter(Enum.FontWeight[typeTokens.DialogDetail.Weight]),
                LineHeight = typeTokens.DialogDetail.LineHeight,
                TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = colors.DialogDetailText,
                Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 114,
            })
        end
        local actions = type(options.Buttons) == "table" and options.Buttons
            or { { Text = "知道了", Primary = true } }
        local horizontal = false
        local actionButtons = {}
        local function fitBody()
            if not body.Parent then return end
            local scale = math.max(self._scale or 1, .01)
            local first = math.max(18, math.ceil(summary.TextBounds.Y / scale),
                math.ceil(summary.AbsoluteSize.Y / scale))
            local second = 0
            if description then
                second = math.max(18, math.ceil(description.TextBounds.Y / scale),
                    math.ceil(description.AbsoluteSize.Y / scale))
                description.Position = UDim2.fromOffset(0, first + dialogTokens.BodyGap)
            end
            local required = first + (description and (second + dialogTokens.BodyGap) or 0)
                + dialogTokens.BodyPaddingY * 2 + 2
            -- Make room for action buttons on short Android viewports.
            local buttonHeight = (horizontal and 1 or #actions) * dialogTokens.ButtonHeight
                + (horizontal and 0 or math.max(0, #actions - 1) * dialogTokens.ButtonGap)
            local bodyMax = math.max(dialogTokens.BodyMinHeight, math.min(dialogTokens.BodyMaxHeight,
                maxDialogHeight - (dialogTokens.HeadingHeight + buttonHeight
                    + dialogTokens.PaddingY * 2 + dialogTokens.Gap * 3 + 16)))
            body.Size = UDim2.new(1, 0, 0,
                math.clamp(required, math.min(dialogTokens.BodyMinHeight, bodyMax), bodyMax))
            body.CanvasSize = UDim2.fromOffset(0, required)
        end
        -- Choose stacked full-width buttons or a right-aligned horizontal row.
        local layout = options.ButtonLayout or options.ActionsLayout or options.Layout
        horizontal = layout == "HorizontalRight" or layout == "Horizontal"
        local available = math.min(width, math.max(220,
            viewport().X / (self._scale or 1) - dialogTokens.EdgeInset * 2))
            - dialogTokens.PaddingX * 2
        -- On narrow screens or with too many actions, do not clip buttons.
        if horizontal and (#actions > dialogTokens.MaxHorizontalButtons
            or available < #actions * dialogTokens.ButtonMinWidth
                + math.max(0, #actions - 1) * dialogTokens.ButtonGap) then
            horizontal = false
        end
        local buttonWidth = horizontal and math.floor(math.min(dialogTokens.ButtonMaxWidth,
            (available - (#actions - 1) * dialogTokens.ButtonGap) / math.max(#actions, 1))) or 0
        local actionRow = create("Frame", {
            Name = "Actions", BackgroundTransparency = 1,
            Size = horizontal and UDim2.new(1, 0, 0, dialogTokens.ButtonHeight)
                or UDim2.new(1, 0, 0, 0),
            AutomaticSize = horizontal and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
            LayoutOrder = 4, ZIndex = 113, Parent = card,
        }, { list(horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            dialogTokens.ButtonGap,
            horizontal and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left,
            Enum.VerticalAlignment.Center) })
        local errorLabel = text({
            Name = "Error", Parent = card, Text = "",
            TextSize = typeTokens.DialogError.Size,
            FontFace = inter(Enum.FontWeight[typeTokens.DialogError.Weight]),
            TextColor3 = colors.DialogErrorText,
            TextWrapped = true, Visible = false,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 3, ZIndex = 113,
        })
        local handle = { Layer = layer, Card = card, Body = body,
            Closed = false, Loading = false, Feedback = nil, ActiveAction = nil }
        local function renderBusy()
            for _, item in actionButtons do
                local btn = item.Button
                local disabled = handle.Loading
                btn.Active = not disabled
                btn.TextTransparency = disabled and .35 or 0
                btn.Text = disabled and handle.ActiveAction == item.Button
                    and item.BusyText or item.Label
            end
            closeButton.Active = not handle.Loading
        end
        function handle:SetLoading(value)
            if self.Closed then return false end
            self.Loading = value == true
            if not self.Loading then self.ActiveAction = nil end
            renderBusy()
            return true
        end
        function handle:SetFeedback(success, message)
            if self.Closed then return false end
            self.Feedback = success == true and "Success" or "Error"
            errorLabel.Text = tostring(message or "")
            errorLabel.Visible = errorLabel.Text ~= ""
            errorLabel.TextColor3 = self.Hub:GetToken(
                self.Feedback == "Success" and "Color.Success" or "Color.DialogErrorText")
            return true
        end
        local connections = {}
        local function bind(signal, fn)
            local conn = signal:Connect(fn)
            table.insert(connections, conn)
            return conn
        end
        function handle:SetError(message)
            return self:SetFeedback(false, message)
        end
        function handle:SetContent(message)
            if self.Closed then return end
            summary.Text = tostring(message or "")
            fitBody()
        end
        function handle:Close()
            if self.Closed then return end
            self.Closed = true
            self.Loading = false
            local hub = self.Hub
            layer.Active = false
            hub:_overlayUnregister("Prompt", self)
            -- When a hub is being torn down, avoid retaining any animation callbacks.
            if hub._destroyed then
                if layer.Parent then layer:Destroy() end
                return
            end
            Motion.play(hub, "action-dialog-exit:" .. tostring(layer), layer,
                { BackgroundTransparency = 1 }, Motion.Presets.Dismiss)
            Motion.play(hub, "action-dialog-holder:" .. tostring(layer), holder,
                { Position = UDim2.new(.5, 0, .5, 8) }, Motion.Presets.Dismiss,
                function() if layer.Parent then layer:Destroy() end end)
            if type(options.OnClose) == "function" then
                local ok, err = pcall(options.OnClose, self)
                if not ok then warn("[RelaxUI Dialog] OnClose: " .. tostring(err)) end
            end
        end
        handle.Hub = self
        -- A modal shade consumes native clicks even when global routing is bypassed.
        bind(layer.MouseButton1Click, function()
            local top = self:_overlayTop()
            if options.CloseOnOutside == true and not handle.Loading
                and top and top.Owner == handle then handle:Close() end
        end)
        bind(closeButton.MouseButton1Click, function()
            local top = self:_overlayTop()
            if not handle.Loading and top and top.Owner == handle then handle:Close() end
        end)
        bind(summary:GetPropertyChangedSignal("TextBounds"), fitBody)
        bind(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
            if handle.Closed then return end
            availableHeight = math.max(120, viewport().Y / math.max(self._scale or 1, .01)
                - topInset() / math.max(self._scale or 1, .01) - 28)
            maxDialogHeight = math.min(self.Tokens.Components.Dialog.MaxHeight, availableHeight)
            sizeLimit.MaxSize = Vector2.new(width, maxDialogHeight)
            fitBody()
        end)
        if description then bind(description:GetPropertyChangedSignal("TextBounds"), fitBody) end
        bind(layer.Destroying, function()
            for _, action in actionButtons do
                Motion.cancel(self, "dialog-action-hover:" .. tostring(action.Button))
                Motion.cancel(self, "dialog-action-press:" .. tostring(action.Button))
            end
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            handle.Closed = true
            self:_overlayUnregister("Prompt", handle)
        end)
        for index, option in actions do
            if type(option) == "table" then
                local primary = option.Primary == true or option.Style == "Primary"
                local danger = option.Danger == true or option.Style == "Danger"
                local btn = create("TextButton", {
                    Name = "Action_" .. index, Text = actionText(option.Text or option.Title, "确定"),
                    BackgroundColor3 = colors[primary and "DialogPrimarySurface" or "DialogButtonSurface"],
                    TextColor3 = colors[primary and "DialogPrimaryText" or
                        (danger and "DialogDangerText" or "DialogButtonText")],
                    FontFace = inter(Enum.FontWeight[typeTokens.DialogButton.Weight]),
                    TextSize = typeTokens.DialogButton.Size,
                    LineHeight = typeTokens.DialogButton.LineHeight,
                    AutoButtonColor = false,
                    Size = horizontal and UDim2.fromOffset(buttonWidth, dialogTokens.ButtonHeight)
                        or UDim2.new(1, 0, 0, dialogTokens.ButtonHeight),
                    LayoutOrder = index, ZIndex = 114, Parent = actionRow,
                }, { corner(dialogTokens.ButtonRadius) })
                local outline
                if not primary then
                    outline = stroke(colors.DialogButtonBorder)
                    outline.Parent = btn
                end
                table.insert(actionButtons, { Button = btn, Primary = primary,
                    Danger = danger, Border = outline, Label = btn.Text,
                    BusyText = actionText(option.LoadingText, "处理中…") })
                bind(btn.MouseEnter, function()
                    if not handle.Loading and not handle.Closed then
                        Motion.play(self, "dialog-action-hover:" .. tostring(btn), btn,
                            { BackgroundTransparency = .12 }, Motion.Presets.Micro)
                    end
                end)
                bind(btn.MouseLeave, function()
                    Motion.play(self, "dialog-action-hover:" .. tostring(btn), btn,
                        { BackgroundTransparency = 0 }, Motion.Presets.Micro)
                end)
                bind(btn.MouseButton1Down, function()
                    if not handle.Loading and not handle.Closed then
                        Motion.play(self, "dialog-action-press:" .. tostring(btn), btn,
                            { BackgroundTransparency = .22 }, Motion.Presets.Micro)
                    end
                end)
                bind(btn.MouseButton1Up, function()
                    Motion.play(self, "dialog-action-press:" .. tostring(btn), btn,
                        { BackgroundTransparency = 0 }, Motion.Presets.Micro)
                end)
                bind(btn.MouseButton1Click, function()
                    local top = self:_overlayTop()
                    if handle.Closed or handle.Loading or not top or top.Owner ~= handle then return end
                    handle.ActiveAction = btn
                    handle:SetLoading(true)
                    handle:SetFeedback(false, "")
                    local keep = option.KeepOpen == true
                    if type(option.Callback) == "function" then
                        -- Support both Callback(dialog) and older Callback(_, dialog).
                        local ok, result = pcall(option.Callback, handle, handle)
                        if handle.Closed then return end
                        if not ok then
                            handle:SetLoading(false)
                            handle:SetError(tostring(result))
                            return
                        end
                        if result == false then keep = true end
                    end
                    -- Callbacks may deliberately retain the busy state for
                    -- asynchronous work; returning false leaves the dialog
                    -- open without a second immediate submission.
                    if handle.Closed then return end
                    if not keep then handle:Close()
                    elseif not option.Async then handle:SetLoading(false) end
                end)
            end
        end
        -- Live semantic bindings own color/typography/radius. Geometry that
        -- depends on multiple tokens is refreshed together by one observer.
        local function bindStyle(inst, property, path)
            if inst then self:BindToken(inst, property, path) end
        end
        for _, spec in {
            { layer, "BackgroundColor3", "Color.DialogScrim" },
            { card, "BackgroundColor3", "Color.DialogSurface" },
            { divider, "BackgroundColor3", "Color.BorderSubtle" },
            { body, "BackgroundColor3", "Color.DialogBodySurface" },
            { body, "BackgroundTransparency", "Components.Dialog.BodyTransparency" },
            { iconPlate, "BackgroundColor3", "Color.DialogIconSurface" },
            { titleLabel, "TextSize", "Typography.DialogTitle.Size" },
            { titleLabel, "LineHeight", "Typography.DialogTitle.LineHeight" },
            { titleLabel, "TextColor3", "Color.DialogTitle" },
            { summary, "TextSize", "Typography.DialogBody.Size" },
            { summary, "LineHeight", "Typography.DialogBody.LineHeight" },
            { summary, "TextColor3", "Color.DialogBodyText" },
            { errorLabel, "TextSize", "Typography.DialogError.Size" },

            { iconPlate:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Dialog.IconPlateRadius" },
            { card:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Dialog.Radius" },
            { body:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Dialog.BodyRadius" },
            { card:FindFirstChildOfClass("UIStroke"), "Color", "Color.DialogBorder" },
        } do bindStyle(spec[1], spec[2], spec[3]) end
        if description then
            bindStyle(description, "TextSize", "Typography.DialogDetail.Size")
            bindStyle(description, "LineHeight", "Typography.DialogDetail.LineHeight")
            bindStyle(description, "TextColor3", "Color.DialogDetailText")
        end
        local iconNode = headingIcon or iconPlate:FindFirstChild("DialogIconFallback")
        local closeNode = closeGlyph or closeButton:FindFirstChild("DialogCloseFallback")
        if iconNode then
            bindStyle(iconNode, headingIcon and "ImageColor3" or "TextColor3", "Color.DialogIcon")
        end
        if closeNode then
            bindStyle(closeNode, closeGlyph and "ImageColor3" or "TextColor3", "Color.DialogCloseIcon")
        end
        for _, spec in actionButtons do
            bindStyle(spec.Button, "TextSize", "Typography.DialogButton.Size")
            bindStyle(spec.Button, "LineHeight", "Typography.DialogButton.LineHeight")
            bindStyle(spec.Button, "BackgroundColor3",
                spec.Primary and "Color.DialogPrimarySurface" or "Color.DialogButtonSurface")
            bindStyle(spec.Button, "TextColor3", spec.Primary and "Color.DialogPrimaryText"
                or (spec.Danger and "Color.DialogDangerText" or "Color.DialogButtonText"))
            bindStyle(spec.Button:FindFirstChildOfClass("UICorner"), "CornerRadius",
                "Components.Dialog.ButtonRadius")
            if spec.Border then bindStyle(spec.Border, "Color", "Color.DialogButtonBorder") end
        end
        local geometryReady = false
        local function syncGeometry()
            if handle.Closed or not card.Parent then return end
            if geometryReady then
                layer.BackgroundTransparency = self.Tokens.Components.Dialog.ScrimTransparency
            end
            dialogTokens = self.Tokens.Components.Dialog
            typeTokens = self.Tokens.Typography
            width = math.clamp(tonumber(options.Width) or dialogTokens.Width,
                dialogTokens.MinWidth, dialogTokens.MaxWidth)
            availableHeight = math.max(120,
                viewport().Y / math.max(self._scale or 1, .01)
                    - topInset() / math.max(self._scale or 1, .01)
                    - dialogTokens.EdgeInset * 2)
            maxDialogHeight = math.min(dialogTokens.MaxHeight, availableHeight)
            sizeLimit.MaxSize = Vector2.new(width, maxDialogHeight)
            holder.Size = UDim2.new(1, -dialogTokens.EdgeInset * 2, 0, 0)
            local cardPadding = card:FindFirstChildOfClass("UIPadding")
            if cardPadding then
                cardPadding.PaddingTop = UDim.new(0, dialogTokens.PaddingY)
                cardPadding.PaddingBottom = UDim.new(0, dialogTokens.PaddingY)
                cardPadding.PaddingLeft = UDim.new(0, dialogTokens.PaddingX)
                cardPadding.PaddingRight = UDim.new(0, dialogTokens.PaddingX)
            end
            local cardList = card:FindFirstChildOfClass("UIListLayout")
            if cardList then cardList.Padding = UDim.new(0, dialogTokens.Gap) end
            local bodyPadding = body:FindFirstChildOfClass("UIPadding")
            if bodyPadding then
                bodyPadding.PaddingTop = UDim.new(0, dialogTokens.BodyPaddingY)
                bodyPadding.PaddingBottom = UDim.new(0, dialogTokens.BodyPaddingY)
                bodyPadding.PaddingLeft = UDim.new(0, dialogTokens.BodyPaddingX)
                bodyPadding.PaddingRight = UDim.new(0, dialogTokens.BodyPaddingX)
            end
            heading.Size = UDim2.new(1, 0, 0, dialogTokens.HeadingHeight)
            iconPlate.Size = UDim2.fromOffset(dialogTokens.IconPlateSize,
                dialogTokens.IconPlateSize)
            if headingIcon then
                headingIcon.Size = UDim2.fromOffset(dialogTokens.IconSize, dialogTokens.IconSize)
            elseif iconNode then iconNode.TextSize = dialogTokens.IconSize end
            titleLabel.Position = UDim2.fromOffset(dialogTokens.IconPlateSize
                + dialogTokens.TitleGap, dialogTokens.TitleTop)
            titleLabel.Size = UDim2.new(1,
                -(dialogTokens.IconPlateSize + dialogTokens.TitleGap
                    + dialogTokens.CloseSize + 2),
                0, dialogTokens.HeadingHeight - dialogTokens.TitleTop)
            closeButton.Size = UDim2.fromOffset(dialogTokens.CloseSize, dialogTokens.CloseSize)
            if closeGlyph then
                closeGlyph.Size = UDim2.fromOffset(dialogTokens.CloseIconSize,
                    dialogTokens.CloseIconSize)
            elseif closeNode then closeNode.TextSize = dialogTokens.CloseIconSize + 2 end
            titleLabel.FontFace = inter(Enum.FontWeight[typeTokens.DialogTitle.Weight])
            summary.FontFace = inter(Enum.FontWeight[typeTokens.DialogBody.Weight])
            errorLabel.FontFace = inter(Enum.FontWeight[typeTokens.DialogError.Weight])
            if description then
                description.FontFace = inter(Enum.FontWeight[typeTokens.DialogDetail.Weight])
            end
            available = math.min(width, math.max(220,
                viewport().X / math.max(self._scale or 1, .01)
                    - dialogTokens.EdgeInset * 2)) - dialogTokens.PaddingX * 2
            horizontal = (layout == "HorizontalRight" or layout == "Horizontal")
                and #actions <= dialogTokens.MaxHorizontalButtons
                and available >= #actions * dialogTokens.ButtonMinWidth
                    + math.max(0, #actions - 1) * dialogTokens.ButtonGap
            local rowLayout = actionRow:FindFirstChildOfClass("UIListLayout")
            if rowLayout then
                rowLayout.FillDirection = horizontal and Enum.FillDirection.Horizontal
                    or Enum.FillDirection.Vertical
                rowLayout.HorizontalAlignment = horizontal and Enum.HorizontalAlignment.Right
                    or Enum.HorizontalAlignment.Left
                rowLayout.Padding = UDim.new(0, dialogTokens.ButtonGap)
            end
            actionRow.AutomaticSize = horizontal and Enum.AutomaticSize.None
                or Enum.AutomaticSize.Y
            actionRow.Size = UDim2.new(1, 0, 0, horizontal and dialogTokens.ButtonHeight or 0)
            buttonWidth = horizontal and math.floor(math.min(dialogTokens.ButtonMaxWidth,
                (available - math.max(0, #actions - 1) * dialogTokens.ButtonGap)
                    / math.max(#actions, 1))) or 0
            for _, action in actionButtons do
                action.Button.Size = horizontal and UDim2.fromOffset(buttonWidth, dialogTokens.ButtonHeight)
                    or UDim2.new(1, 0, 0, dialogTokens.ButtonHeight)
                action.Button.FontFace = inter(Enum.FontWeight[typeTokens.DialogButton.Weight])
            end
            fitBody()
            if handle.Feedback then
                errorLabel.TextColor3 = self:GetToken(handle.Feedback == "Success"
                    and "Color.Success" or "Color.DialogErrorText")
            end
            geometryReady = true
        end
        local listener = self:WatchDesignTokens(syncGeometry)
        bind(layer.Destroying, function()
            if listener then listener:Disconnect() end
        end)
        self:_overlayRegister("Prompt", handle, {
            Content = holder, Modal = true, Outside = false, Escape = options.Escape ~= false,
            Close = function() handle:Close() end,
        })
        syncGeometry()
        Motion.play(self, "action-dialog-enter:" .. tostring(layer), layer,
            { BackgroundTransparency = dialogTokens.ScrimTransparency }, Motion.Presets.Control)
        Motion.play(self, "action-dialog-holder:" .. tostring(layer), holder,
            { Position = UDim2.fromScale(.5, .5) }, Motion.Presets.Panel)
        return handle
    end

    function Hub:_ensureLockOverlay(control)
        local row = control.Frame
        if control._lockOverlay and control._lockOverlay.Parent then return control._lockOverlay end
        local overlay = create("TextButton", {
            Name = "ControlLockShade", Parent = row, Text = "",
            BackgroundColor3 = self.Tokens.Color.LockShade,
            BackgroundTransparency = self:GetToken("Components.Dialog.LockTransparency"),
            Active = true, AutoButtonColor = false, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 45,
        }, { corner(self:GetToken("Components.Dialog.LockRadius")) })
        -- A fully transparent shake target: only the lock glyph is visible.
        local iconPlate = create("Frame", {
            Name = "LockPlate", Parent = overlay, BackgroundTransparency = 1,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromOffset(self:GetToken("Components.Dialog.LockPlateSize"),
                self:GetToken("Components.Dialog.LockPlateSize")), ZIndex = 46,
        })
        local glyph = iconLabel("lock", self:GetToken("Components.Dialog.LockIconSize"),
            self.Tokens.Color.LockIcon, {
            Parent = iconPlate, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5), ZIndex = 47,
        })
        if not glyph then
            -- Draw a simple padlock fallback instead of relying on missing emoji glyphs.
            create("Frame", {
                Name = "Shackle", Parent = iconPlate, BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 7), Size = UDim2.fromOffset(12, 13),
                ZIndex = 47,
            }, { corner(7), stroke(themeColor(self.Theme, "Text"), 2) })
            create("Frame", {
                Name = "LockBody", Parent = iconPlate,
                BackgroundColor3 = themeColor(self.Theme, "Text"),
                Position = UDim2.fromOffset(9, 17), Size = UDim2.fromOffset(18, 12),
                ZIndex = 48,
            }, { corner(3) })
        end
        self:BindToken(overlay, "BackgroundColor3", "Color.LockShade")
        self:BindToken(overlay, "BackgroundTransparency", "Components.Dialog.LockTransparency")
        self:BindToken(overlay:FindFirstChildOfClass("UICorner"), "CornerRadius",
            "Components.Dialog.LockRadius")
        if glyph then self:BindToken(glyph, "ImageColor3", "Color.LockIcon") end
        control._lockOverlay, control._lockIcon = overlay, iconPlate
        control._lockShakeId = 0
        local hub = self
        hub:_connect(row.Destroying, function()
            control._lockShakeId += 1
            if control._lockIcon then cancelMotion(control._lockIcon) end
            control._lockOverlay = nil
            control._lockIcon = nil
        end)
        hub:_connect(overlay.MouseButton1Click, function()
            if hub._destroyed or control._disposed then return end
            local available = control:IsAvailable()
            if available then return end
            hub:_shakeControlLock(control)
            hub:_openLockedReason(control)
        end)
        return overlay
    end

    function Hub:_shakeControlLock(control)
        local plate = control._lockIcon
        if not plate or not plate.Parent then return end
        control._lockShakeId = (control._lockShakeId or 0) + 1
        local id = control._lockShakeId
        cancelMotion(plate)
        plate.Position = UDim2.fromScale(.5, .5)
        task.spawn(function()
            for _, dx in { -5, 5, -4, 4, -2, 0 } do
                if self._destroyed or control._disposed or not plate.Parent
                    or control._lockShakeId ~= id then return end
                local move = tween(plate, TweenInfo.new(.045, Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out), { Position = UDim2.new(.5, dx, .5, 0) })
                move.Completed:Wait()
            end
            if not self._destroyed and plate.Parent and control._lockShakeId == id then
                plate.Position = UDim2.fromScale(.5, .5)
            end
        end)
    end

    function Hub:_openLockedReason(control)
        if self._destroyed then return end
        local allowed, reason = control:IsAvailable()
        if allowed then return nil end
        reason = actionText(reason, "此控件当前已锁定。")
        local previous = self._activeLockDialog
        if previous and not previous.Closed then
            if self._activeLockControl == control then
                previous:SetContent(reason)
                return previous
            end
            previous:Close()
            -- Repeated touches on different controls must not accumulate
            -- animation-out layers behind the newly opened modal.
            if previous.Layer and previous.Layer.Parent then previous.Layer:Destroy() end
        end
        local custom = control._lockOptions or {}
        local actions = custom.Actions
        if type(actions) ~= "table" or #actions == 0 then
            actions = {
                { Text = "复制原因", Callback = function(handle)
                    if typeof(setclipboard) == "function" then
                        local ok = pcall(setclipboard, reason)
                        if ok then handle:SetError("已复制锁定原因"); return false end
                    end
                    handle:SetError("当前环境无法复制文本")
                    return false
                end, KeepOpen = true },
                { Text = "知道了", Primary = true },
            }
        else
            local adapted = {}
            for _, spec in actions do
                if type(spec) == "table" then
                    local original = spec.Callback
                    local action = table.clone(spec)
                    if type(original) == "function" then
                        action.Callback = function(handle)
                            return original(control, handle)
                        end
                    end
                    table.insert(adapted, action)
                end
            end
            actions = #adapted > 0 and adapted or { { Text = "知道了", Primary = true } }
        end
        local dialog = self:OpenActionDialog({
            Title = actionText(custom.Title, control.Name .. " · 已锁定"),
            Content = reason, Details = custom.Details,
            Icon = custom.Icon or "lock", Width = custom.Width,
            Buttons = actions,
            ButtonLayout = custom.ButtonLayout or custom.ActionsLayout or custom.Layout,
            CloseOnOutside = custom.CloseOnOutside == true,
            OnClose = function(handle)
                if self._activeLockDialog == handle then
                    self._activeLockDialog = nil
                    self._activeLockControl = nil
                end
                if type(custom.OnClose) == "function" then pcall(custom.OnClose, control, handle) end
            end,
        })
        self._activeLockDialog = dialog
        self._activeLockControl = control
        return dialog
    end

    function Hub:_syncLockOverlay(control)
        if not control or not control.Frame or not control.Frame.Parent or self._destroyed then return end
        local available = control:IsAvailable()
        if available then
            if control._lockOverlay then
                control._lockOverlay.Visible = false
                control._lockShakeId = (control._lockShakeId or 0) + 1
                if control._lockIcon then
                    cancelMotion(control._lockIcon)
                    control._lockIcon.Position = UDim2.fromScale(.5, .5)
                end
            end
            if self._activeLockControl == control and self._activeLockDialog then
                self._activeLockDialog:Close()
            end
        else
            self:_ensureLockOverlay(control).Visible = true
            if self._activeLockControl == control and self._activeLockDialog
                and not self._activeLockDialog.Closed then
                local _, reason = control:IsAvailable()
                self._activeLockDialog:SetContent(actionText(reason, "此控件当前已锁定。"))
            end
        end
    end
end

end

-- Shared plumbing for every control: registry, flag, recipe, visibility, safe callbacks.
function Section:_control(kind: string, options, row: Frame, rawArgs)
	local control = {
		Type = kind,
		Name = options.Name or kind,
		Flag = options.Flag,
		Frame = row,
		Section = self,
		Callback = options.Callback or function() end,
		_internal = self._internal,
		_changed = {},
		_dataObservers = {},
		_dataSubscriptions = {},
		Requires = mergedRequirements(self.Requires, options.Requires),
        _locked = options.Locked == true or options.State == "Locked",
        _lockReason = options.LockReason or (type(options.Lock) == "table" and options.Lock.Reason),
        _lockOptions = type(options.Lock) == "table" and table.clone(options.Lock) or {
            Title = options.LockTitle, Details = options.LockDetails,
            Actions = options.LockActions,
        },
	}
    function control:IsAvailable()
        if self._locked then return false, self._lockReason or "该控件已锁定" end
        return self.Section.Hub:CanUse(self.Requires)
    end
    function control:GetAvailability()
        local allowed, reason = self:IsAvailable()
        return allowed and "Available" or "Locked", reason
    end
    function control:IsLocked() return not self:IsAvailable() end
    function control:SetLocked(on, reason, lockOptions)
        self._locked = on == true
        if type(reason) == "table" then
            lockOptions = reason
            reason = reason.Reason
        end
        if reason ~= nil then self._lockReason = tostring(reason) end
        if type(lockOptions) == "table" then self._lockOptions = table.clone(lockOptions) end
        self.Section.Hub:_syncLockOverlay(self)
        self:_dataEvent("Locked", self._locked)
        return self
    end
    function control:SetAvailability(state, reason, lockOptions)
        assert(state == "Available" or state == "Locked", "state must be Available or Locked")
        return self:SetLocked(state == "Locked", reason, lockOptions)
    end
    function control:SetLockActions(actions)
        assert(type(actions) == "table", "lock actions must be a table")
        self._lockOptions = self._lockOptions or {}
        self._lockOptions.Actions = table.clone(actions)
        return self
    end
    function control:ShowLockReason()
        if self:IsAvailable() then return nil end
        return self.Section.Hub:_openLockedReason(self)
    end
	function control:OnChanged(fn)
		table.insert(self._changed, fn)
		return self
	end
	function control:OnDataEvent(event, fn)
		assert(type(event) == "string" and event ~= "", "event name required")
		assert(type(fn) == "function", "data event listener must be function")
		assert(not self._disposed and not self.Section.Hub._destroyed, "control destroyed")
		local slot = self._dataObservers[event] or {}
		self._dataObservers[event] = slot
		table.insert(slot, fn)
		local subscription = { Connected = true }
		local owner, hub = self, self.Section.Hub
		owner._dataSubscriptions[subscription] = true
		hub._directDataSubscriptions = hub._directDataSubscriptions or {}
		hub._directDataSubscriptions[subscription] = true
		function subscription:Disconnect()
			if not self.Connected then return end
			self.Connected = false
			local at = table.find(slot, fn)
			if at then table.remove(slot, at) end
			owner._dataSubscriptions[self] = nil
			if hub._directDataSubscriptions then hub._directDataSubscriptions[self] = nil end
		end
		return subscription
	end
	function control:_dataEvent(event, payload)
		if self._disposed or self.Section.Hub._destroyed then return end
		local listeners = self._dataObservers[event]
		if not listeners then return end
		for _, fn in table.clone(listeners) do
			local ok, err = xpcall(fn, debug.traceback, payload, self)
			if not ok then recordError(tostring(err), tostring(err), self.Name .. "." .. event) end
		end
	end
	function control:OffChanged(fn)
		local index = table.find(self._changed, fn)
		if not index then return false end
		table.remove(self._changed, index)
		return true
	end
	function control:SetVisible(v: boolean)
		self._hidden = not v
		self.Frame.Visible = v
	end
	function control:_emit(...)
		local available, reason = self:IsAvailable()
		if not available then return false, reason end
		local args = table.pack(...)
		scheduleControlCallback(self, args, function(latest)
			if not self:IsAvailable() then return end
			-- Each observer is isolated; one failure must not suppress the rest.
			local ok, err = xpcall(self.Callback, debug.traceback, table.unpack(latest, 1, latest.n))
			if not ok then
				local message = string.match(tostring(err), "^[^\n]*")
				recordError(message, tostring(err), self.Name)
				warn("[RiftUI] " .. self.Name .. " callback error: " .. message)
				local hub = self.Section.Hub
				local now = os.clock()
				if not hub._destroyed and (not self._lastErrorToast or now - self._lastErrorToast > 4) then
					self._lastErrorToast = now
					hub:Notify({
						Title = self.Name .. " callback failed",
						Content = message, Tone = hub.Theme.Danger,
						Icon = "triangle-alert", Duration = 6,
					})
				end
			end
			for _, fn in self._changed do
				if self.Section.Hub._destroyed then return end
				if self:IsAvailable() then
					local observerOk, observerErr = xpcall(fn, debug.traceback, table.unpack(latest, 1, latest.n))
					if not observerOk then
						recordError(tostring(observerErr), tostring(observerErr), self.Name .. ".OnChanged")
					end
				end
			end
		end)
	end
	if control.Flag then
		RiftUI.Flags[control.Flag] = control
	end
	-- these print Description under their name already; everything else shows it on hover
	local inline = { Toggle = true, Keybind = true, Dropdown = true, ColorPicker = true, Stepper = true, PlayerPicker = true }
	local tip = options.Tooltip or (not inline[kind] and options.Description)
	if type(tip) == "string" and tip ~= "" then
		control.Tooltip = tip
		self.Hub:_attachTip(row, tip)
	end
	table.insert(self.Controls, control)
	local moduleParent = self._isModuleCard and self or self._moduleCard
	if moduleParent then
		control._moduleCard = moduleParent
		table.insert(moduleParent._moduleControls, control)
		-- Capture explicit defaults immediately, before the caller can mutate
		-- a newly created control. Deferred Get() is only a fallback.
		if options.Default ~= nil then
			control.DefaultValue = type(options.Default) == "table"
				and table.clone(options.Default) or options.Default
		end
		task.defer(function()
			if not self.Hub._destroyed and control.Get and control.DefaultValue == nil then
				local ok, value = pcall(control.Get, control)
				if ok then control.DefaultValue = type(value) == "table"
					and table.clone(value) or value end
			end
		end)
	end
	self.Hub:_attachControlTheme(control)
    self.Hub:_syncLockOverlay(control)
	self.Hub:_record(self, kind, rawArgs or options, control)
	return control
end

function Section:_labels(row: Frame, name: string, description: string?, rightWidth: number)
	local theme = self.Hub.Theme
	local holder = create("Frame", {
		Name = "Labels",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -rightWidth - 8, 1, 0),
		Parent = row,
	}, { list(Enum.FillDirection.Vertical, 1, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local title = text({ Parent = holder, Name = "Title", Text = name,
        TextSize = self.Hub:GetToken("Typography.ControlLabel.Size"),
        TextColor3 = themeColor(theme, "Text"), Size = UDim2.new(1, 0, 0, 16),
        TextTruncate = Enum.TextTruncate.AtEnd })
    self.Hub:BindToken(title, "TextSize", "Typography.ControlLabel.Size")
	if description and description ~= "" then
		local descLabel = text({
			Parent = holder,
			Name = "Description",
			Text = description,
			TextSize = self.Hub:GetToken("Typography.ControlDescription.Size"),
			TextColor3 = self.Hub:GetToken("Color.TextMuted"),
			TextWrapped = true,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
		})
        self.Hub:BindToken(descLabel, "TextSize", "Typography.ControlDescription.Size")
        self.Hub:BindToken(descLabel, "TextColor3", "Color.TextMuted")
		row.AutomaticSize = Enum.AutomaticSize.Y
		create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = holder })
		holder.Size = UDim2.new(1, -rightWidth - 8, 0, 0)
		holder.AutomaticSize = Enum.AutomaticSize.Y
	end
	return title
end

---------------------------------------------------------------- Toggle
function Section:Toggle(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local row = self:_row(34, "Toggle_" .. (options.Name or ""))
	local c = self:_control("Toggle", options, row)
	c.Value = options.Default == true
	local titleLabel = self:_labels(row, c.Name, options.Description, 24)
	local box = create("Frame", {
		Name = "Check",
		BackgroundColor3 = themeColor(theme, "Field"),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(16, 16),
		Parent = row,
	}, { corner(4) })
	local boxStroke = stroke(themeColor(theme, "FieldStroke"))
	boxStroke.Parent = box
	local pop = create("UIScale", { Name = "Pop", Parent = box })
	local mark = iconLabel("check", 12, theme.AccentText, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ImageTransparency = 1,
		Parent = box,
	})
	local hit = create("TextButton", { Name = "Hit", BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = row })

	local function render(animate: boolean)
		local on = c.Value
		local goals = { BackgroundColor3 = on and themeColor(theme, "Accent") or themeColor(theme, "Field") }
		if animate then
			tween(box, FAST, goals)
			tween(boxStroke, FAST, { Color = on and themeColor(theme, "Accent") or themeColor(theme, "FieldStroke") })
			if mark then
				tween(mark, FAST, { ImageTransparency = on and 0 or 1 })
			end
			if hub:GetControlTheme() == "Rounded" then
				-- Rounded uses a separate thumb; never scale the switch parent.
				cancelMotion(pop)
				pop.Scale = 1
			elseif on then
				pop.Scale = 0.8
				tween(pop, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
			end
		else
			setThemed(box, "BackgroundColor3", goals.BackgroundColor3)
			setThemed(boxStroke, "Color", on and themeColor(theme, "Accent") or themeColor(theme, "FieldStroke"))
			if mark then
				mark.ImageTransparency = on and 0 or 1
			end
		end
		if titleLabel then
			setThemed(titleLabel, "TextColor3", on and themeColor(theme, "Text") or themeColor(theme, "SubText"))
		end
	end
	hub:_connect(hit.MouseEnter, function()
		if not c.Value then
			tween(boxStroke, FAST, { Color = themeColor(theme, "Knob") })
		end
	end)
	hub:_connect(hit.MouseLeave, function()
		if not c.Value then
			tween(boxStroke, FAST, { Color = themeColor(theme, "FieldStroke") })
		end
	end)
	function c:Set(value: boolean, silent: boolean?)
		value = value == true
		if self.Value == value then
			return
		end
		self.Value = value
		render(true)
		self.Section.Tab:_recount()
		for _, fn in self._dependents or {} do
			task.spawn(fn, value)
		end
		if not silent then
			hub:PlayUISound(value and "ToggleOn" or "ToggleOff")
			self:_emit(value)
		end
	end
	function c:Get()
		return self.Value
	end
	render(false)
	hub:_connect(hit.MouseButton1Click, function()
		c:Set(not c.Value)
	end)
	self.Tab:_recount()
	if c.Value and not hub._replaying then
		if #c.Requires > 0 and not c:IsAvailable() then c._pendingRequirementDefault = true else c:_emit(true) end
	end
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Button
function Section:Button(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local hub, theme = self.Hub, self.Hub.Theme
	local row = self:_row(hub:GetToken("Components.Button.Height") + 8, "Button_" .. (options.Name or ""))
	local c = self:_control("Button", options, row)
	local base = options.Danger and hub:GetToken("Color.InputSurface")
        or hub:GetToken("Color.ButtonSurface")
	local btn = create("TextButton", {
		Name = "Button",
		BackgroundColor3 = base,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, hub:GetToken("Components.Button.Height")),
		Text = c.Name,
		FontFace = inter(Enum.FontWeight[hub:GetToken("Typography.ButtonLabel.Weight")]),
		TextSize = hub:GetToken("Typography.ButtonLabel.Size"),
		TextColor3 = options.Danger and themeColor(theme, "Danger") or themeColor(theme, "Text"),
		AutoButtonColor = false,
		Parent = row,
	}, { corner(hub:GetToken("Components.Button.Radius")),
        stroke(hub:GetToken("Color.ButtonBorder")) })
    hub:BindToken(btn, "TextSize", "Typography.ButtonLabel.Size")
    if not options.Danger then hub:BindToken(btn, "BackgroundColor3", "Color.ButtonSurface") end
    hub:BindToken(btn, "TextColor3", "Color.ButtonText")
    hub:BindToken(btn:FindFirstChildOfClass("UIStroke"), "Color", "Color.ButtonBorder")
    hub:BindToken(btn:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Button.Radius")
	local press = create("UIScale", { Name = "Press", Parent = btn })
	hub:_connect(btn.MouseEnter, function()
		tween(btn, FAST, { BackgroundColor3 = hub:GetToken("Color.ButtonHover") })
	end)
	hub:_connect(btn.MouseLeave, function()
		tween(btn, FAST, { BackgroundColor3 = options.Danger
            and hub:GetToken("Color.InputSurface") or hub:GetToken("Color.ButtonSurface") })
		if c._skinPress then c._skinPress(false) end
		if hub:GetControlTheme() == "Rounded" then
			cancelMotion(press)
			press.Scale = 1
		else
			tween(press, FAST, { Scale = 1 })
		end
	end)
	hub:_connect(btn.MouseButton1Down, function()
		if hub:GetControlTheme() == "Rounded" then
			cancelMotion(press)
			press.Scale = 1
			if c._skinPress then c._skinPress(true) end
		else
			tween(press, FAST, { Scale = 0.97 })
		end
	end)
	hub:_connect(btn.MouseButton1Up, function()
		if hub:GetControlTheme() == "Rounded" then
			if c._skinPress then c._skinPress(false) end
		else
			tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		end
	end)
	if options.Window then
		c.Window = options.Window
		btn.TextXAlignment = Enum.TextXAlignment.Left
		padding(0, 30, 0, 10).Parent = btn
		iconLabel("chevron-right", 14, theme.SubText, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 20, 0.5, 0), Parent = btn })
	end
	hub:_connect(btn.MouseButton1Click, function()
		if not c:IsAvailable() then return end
		if c.Window then c.Window:Open() end
		hub:PlayUISound("Click")
		c:_emit()
	end)
	function c:SetText(t: string)
		btn.Text = t
		self.Name = t
	end
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Slider
function Section:Slider(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local min, max = options.Min or 0, options.Max or 100
	local step = options.Step or options.Increment or 1
	local suffix = options.Suffix or ""
	local row = self:_row(46, "Slider_" .. (options.Name or ""))
	local c = self:_control("Slider", options, row)
	c.Min, c.Max, c.Step = min, max, step
	c.Value = math.clamp(round(options.Default or min, step, min), min, max)

	text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 7), Size = UDim2.new(1, -80, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	local box = create("TextBox", {
		Name = "Value",
		BackgroundColor3 = themeColor(theme, "Field"),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 4),
		Size = UDim2.fromOffset(0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		FontFace = MONO,
		TextSize = 12,
		TextColor3 = themeColor(theme, "SubText"),
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = false,
		Text = "",
		Parent = row,
	}, { corner(5), padding(0, 6), create("UISizeConstraint", { MinSize = Vector2.new(30, 22) }) })
	local track = create("Frame", {
		Name = "Track",
		BackgroundColor3 = themeColor(theme, "Track"),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 0, 2),
		Parent = row,
	}, { corner(1) })
	local fill = create("Frame", { Name = "Fill", BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = track }, { corner(1) })
	local knob = create("Frame", {
		Name = "Notch",
		BackgroundColor3 = themeColor(theme, "Accent"),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(4, 14),
		ZIndex = 2,
		Parent = track,
	}, { corner(2) })
	local grow = create("UIScale", { Name = "Grow", Parent = knob })
	local hit = create("TextButton", {
		Name = "Hit",
		BackgroundTransparency = 1,
		Text = "",
		Position = UDim2.fromOffset(-6, 24),
		Size = UDim2.new(1, 12, 0, 22),
		ZIndex = 3,
		Parent = row,
	})

	local function render()
		local a = (max > min) and (c.Value - min) / (max - min) or 0
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		if not box:IsFocused() then
			box.Text = formatNumber(c.Value, step) .. suffix
		end
	end
	function c:Set(value: number, silent: boolean?)
		value = math.clamp(round(tonumber(value) or min, step, min), min, max)
		if self.Value == value then
			render()
			return
		end
		self.Value = value
		render()
		if not silent then
			hub:PlayUISound("SliderTick")
			self:_emit(value)
		end
	end
	function c:Get()
		return self.Value
	end
	render()

	local function fromX(x: number)
		local p, sz = track.AbsolutePosition, track.AbsoluteSize
		if sz.X <= 0 then return end
		c:Set(min + (max - min) * math.clamp((x - p.X) / sz.X, 0, 1))
	end
	bindPointerDrag(hub, hit, {
		Start = function(input)
			tween(grow, SETTLE, { Scale = hub:GetControlTheme() == "Rounded" and 1.08 or 1.25 })
			if c._skinDrag then c._skinDrag(true) end
			fromX(input.Position.X)
		end,
		Move = function(input)
			fromX(input.Position.X)
			if c._skinDrag then c._skinDrag(true) end
		end,
		End = function()
			tween(grow, SETTLE, { Scale = 1 })
			if c._skinDrag then c._skinDrag(false) end
		end,
	})
	hub:_connect(box.Focused, function()
		box.Text = formatNumber(c.Value, step)
		box.BackgroundTransparency = 0
		setThemed(box, "TextColor3", themeColor(theme, "Text"))
	end)
	hub:_connect(box.FocusLost, function()
		box.BackgroundTransparency = 1
		setThemed(box, "TextColor3", themeColor(theme, "SubText"))
		local n = tonumber((string.gsub(box.Text, "[^%d%.%-]", "")))
		if n then
			c:Set(n)
		end
		render()
	end)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Dropdown
function Section:Dropdown(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local multi = options.Multi == true
	local row = self:_row(34, "Dropdown_" .. (options.Name or ""))
	local c = self:_control("Dropdown", options, row)
	c.Options = table.clone(options.Options or options.Values or {})
	c.Multi = multi
	if multi then
		c.Value = {}
		for _, v in (type(options.Default) == "table" and options.Default or {}) do
			c.Value[v] = true
		end
	else
		c.Value = options.Default or c.Options[1]
	end
	self:_labels(row, c.Name, options.Description, 96)
	local chip = create("TextButton", {
		Name = "Chip",
		BackgroundColor3 = themeColor(theme, "Field"),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	}, {
		corner(6),
		stroke(themeColor(theme, "FieldStroke")),
		padding(0, 6, 0, 8),
		list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
		create("UISizeConstraint", { MaxSize = Vector2.new(120, 24) }),
	})
	local label = text({
		Parent = chip,
		Name = "Value",
		TextSize = 12,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	create("UISizeConstraint", { MaxSize = Vector2.new(90, 24), Parent = label })
	if not iconLabel("chevron-down", 14, theme.SubText, { LayoutOrder = 2, Parent = chip }) then
		text({ Parent = chip, Text = "v", TextSize = 11, TextColor3 = themeColor(theme, "SubText"), Size = UDim2.fromOffset(10, 24), LayoutOrder = 2 })
	end

	local function display(): string
		if multi then
			local picked = {}
			for _, o in c.Options do
				if c.Value[o] then
					table.insert(picked, tostring(o))
				end
			end
			if #picked == 0 then
				return "None"
			elseif #picked > 2 then
				return #picked .. " selected"
			end
			return table.concat(picked, ", ")
		end
		return c.Value ~= nil and tostring(c.Value) or "None"
	end
	local function render()
		label.Text = display()
	end
	function c:Set(value, silent: boolean?)
		if multi then
			local set = {}
			if type(value) == "table" then
				for k, v in value do
					if type(k) == "number" then
						set[v] = true
					elseif v then
						set[k] = true
					end
				end
			end
			self.Value = set
		else
			self.Value = value
		end
		render()
		if not silent then
			hub:PlayUISound("Select")
			self:_emit(self.Value)
		end
	end
	function c:Get()
		return self.Value
	end
	function c:SetOptions(newOptions: { any })
		self.Options = table.clone(newOptions)
		render()
	end
	render()

	hub:_connect(chip.MouseButton1Click, function()
		if hub._popup and hub._popup.Anchor == chip then
			hub:_closePopup()
			return
		end
		local count = #c.Options
		local searchable = count > 8
		local itemH = hub:GetToken("Components.Popup.ItemHeight")
		local h = math.max(1, math.min(count, 7)) * itemH + 8 + (searchable and 34 or 0)
		local frame = create("Frame", {
			Name = "DropdownList",
			BackgroundColor3 = hub:GetToken("Color.PopupSurface"),
			Size = UDim2.fromOffset(hub:GetToken("Components.Popup.Width"), h),
			ZIndex = 41,
		}, { corner(hub:GetToken("Components.Popup.Radius")),
            stroke(hub:GetToken("Color.PopupBorder")), padding(4) })
		local search
		if searchable then
			search = create("TextBox", {
				Name = "Filter",
				BackgroundColor3 = themeColor(theme, "Field"),
				Size = UDim2.new(1, 0, 0, 28),
				PlaceholderText = "Filter",
				PlaceholderColor3 = themeColor(theme, "Muted"),
				Text = "",
				FontFace = inter(),
				TextSize = 12,
				TextColor3 = themeColor(theme, "Text"),
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ZIndex = 42,
				Parent = frame,
			}, { corner(6), padding(0, 8) })
		end
		local scroll = create("ScrollingFrame", {
			Name = "Items",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, searchable and 34 or 0),
			Size = UDim2.new(1, 0, 1, searchable and -34 or 0),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = themeColor(theme, "Knob"),
			ZIndex = 42,
			Parent = frame,
		}, { list(Enum.FillDirection.Vertical, 0) })
		if count == 0 then
			text({ Parent = scroll, Text = "No options", TextColor3 = themeColor(theme, "Muted"), Size = UDim2.new(1, 0, 0, itemH), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 43 })
		end
		local items = {}
		for i, opt in c.Options do
			local selected = if multi then c.Value[opt] == true else c.Value == opt
			local item = create("TextButton", {
				Name = "Item",
				BackgroundColor3 = themeColor(theme, "Tile"),
				BackgroundTransparency = selected and 0 or 1,
				Size = UDim2.new(1, 0, 0, itemH),
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = 43,
				Parent = scroll,
			}, { corner(6), padding(0, 8) })
			text({ Parent = item, Text = tostring(opt), TextSize = 13, Size = UDim2.new(1, -20, 1, 0), ZIndex = 44, TextTruncate = Enum.TextTruncate.AtEnd })
			local check = iconLabel("check", 14, theme.Text, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Visible = selected,
				ZIndex = 44,
				Parent = item,
			})
			items[opt] = item
			item.MouseEnter:Connect(function()
				tween(item, FAST, { BackgroundTransparency = 0 })
			end)
			item.MouseLeave:Connect(function()
				local on = if multi then c.Value[opt] == true else c.Value == opt
				tween(item, FAST, { BackgroundTransparency = on and 0 or 1 })
			end)
			item.MouseButton1Click:Connect(function()
				if multi then
					local v = table.clone(c.Value)
					v[opt] = not v[opt] or nil
					c:Set(v)
					if check then
						check.Visible = v[opt] == true
					end
				else
					c:Set(opt)
					hub:_closePopup()
				end
			end)
		end
		if search then
			search:GetPropertyChangedSignal("Text"):Connect(function()
				local q = string.lower(search.Text)
				for opt, item in items do
					item.Visible = q == "" or string.find(string.lower(tostring(opt)), q, 1, true) ~= nil
				end
			end)
		end
		hub:_openPopup(chip, frame)
        hub:BindToken(frame, "BackgroundColor3", "Color.PopupSurface")
        hub:BindToken(frame:FindFirstChildOfClass("UIStroke"), "Color", "Color.PopupBorder")
        hub:BindToken(frame:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Popup.Radius")
	end)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Input
function Section:Input(options)
	local hub, theme = self.Hub, self.Hub.Theme
	-- MultiLine grows the field to Lines rows of wrapped text; Enter then starts a new line
	-- and the value commits when focus leaves.
	local multi = options.MultiLine == true
	local mono = options.Numeric or options.Code
	local textSize = options.Code and 12 or hub:GetToken("Typography.ControlLabel.Size")
	local boxHeight = multi and (math.clamp(math.floor(options.Lines or 4), 2, 20) * math.ceil(textSize * 1.25) + 12) or hub:GetToken("Components.Input.Height")
	local row = self:_row(boxHeight + 32, "Input_" .. (options.Name or ""))
	local c = self:_control("Input", options, row)
	c.Value = options.Default or ""
	c.MultiLine = multi
	local inputTitle = text({ Parent = row, Name = "Title", Text = c.Name,
        TextSize = hub:GetToken("Typography.ControlLabel.Size"),
        Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 0, 16) })
    hub:BindToken(inputTitle, "TextSize", "Typography.ControlLabel.Size")
	local box = create("TextBox", {
		Name = "Box",
		BackgroundColor3 = hub:GetToken("Color.InputSurface"),
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, boxHeight),
		FontFace = mono and MONO or inter(),
		TextSize = textSize,
		TextColor3 = hub:GetToken("Color.InputText"),
		PlaceholderText = options.Placeholder or "",
		PlaceholderColor3 = themeColor(theme, "Muted"),
		Text = c.Value,
		ClearTextOnFocus = options.ClearOnFocus == true,
		MultiLine = multi,
		TextWrapped = multi,
		ClipsDescendants = multi,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = multi and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		Parent = row,
	}, { corner(hub:GetToken("Components.Input.Radius")),
        multi and padding(6, 8) or padding(0, 8) })
	local boxStroke = stroke(hub:GetToken("Color.InputBorder"))
	boxStroke.Parent = box
    hub:BindToken(box, "BackgroundColor3", "Color.InputSurface")
    hub:BindToken(box, "TextColor3", "Color.InputText")
    hub:BindToken(boxStroke, "Color", "Color.InputBorder")
    hub:BindToken(box:FindFirstChildOfClass("UICorner"), "CornerRadius",
        "Components.Input.Radius")
    if not mono then hub:BindToken(box, "TextSize", "Typography.ControlLabel.Size") end
	function c:Set(value: string, silent: boolean?)
		value = tostring(value or "")
		if options.Numeric then
			value = string.gsub(value, "[^%d%.%-]", "")
		elseif not multi then
			value = string.gsub(value, "[\r\n]+", " ")
		end
		if type(options.MaxLength) == "number" and utf8.len(value) and utf8.len(value) > options.MaxLength then
			value = string.sub(value, 1, (utf8.offset(value, options.MaxLength + 1) or (#value + 1)) - 1)
		end
		self.Value = value
		box.Text = value
		if not silent then
			hub:PlayUISound("InputSubmit")
			self:_emit(value)
		end
	end
	function c:Get()
		return self.Value
	end
	hub:_connect(box.Focused, function()
		hub:PlayUISound("InputFocus")
		tween(boxStroke, FAST, { Color = themeColor(theme, "SubText") })
	end)
	hub:_connect(box.FocusLost, function(enter)
		tween(boxStroke, FAST, { Color = themeColor(theme, "FieldStroke") })
		if options.Finished == false or enter or box.Text ~= c.Value then
			c:Set(box.Text)
		end
	end)
	if options.Finished == false then
		hub:_connect(box:GetPropertyChangedSignal("Text"), function()
			if box:IsFocused() then
				c:Set(box.Text)
			end
		end)
	end
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Keybind
function Section:Keybind(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local row = self:_row(34, "Keybind_" .. (options.Name or ""))
	local c = self:_control("Keybind", options, row)
	c.Value = options.Default
	c.Mode = options.Mode or "Toggle" -- Toggle, Hold, Always
	c.State = c.Mode == "Always"
	c.ChangedCallback = options.ChangedCallback
	local labels = self:_labels(row, c.Name, options.Description, 90).Parent
	local chip = create("TextButton", {
		Name = "Key",
		BackgroundColor3 = themeColor(theme, "Field"),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		FontFace = MONO,
		TextSize = 11,
		TextColor3 = themeColor(theme, "Text"),
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	}, { corner(6), stroke(themeColor(theme, "FieldStroke")), padding(0, 8), create("UISizeConstraint", { MinSize = Vector2.new(40, 24) }) })
	-- The label gets whatever the key chip leaves, so short keys don't truncate long names.
	local function fitLabels()
		local w = chip.AbsoluteSize.X / hub._scale
		labels.Size = UDim2.new(1, -math.ceil(w) - 10, labels.Size.Y.Scale, labels.Size.Y.Offset)
	end
	hub:_connect(chip:GetPropertyChangedSignal("AbsoluteSize"), fitLabels)
	local listening = false
	local function render()
		if listening then
			chip.Text = "Press a key…"
			setThemed(chip, "BackgroundColor3", themeColor(theme, "Accent"))
			setThemed(chip, "TextColor3", themeColor(theme, "AccentText"))
		else
			chip.Text = keyName(c.Value)
			setThemed(chip, "BackgroundColor3", themeColor(theme, "Field"))
			setThemed(chip, "TextColor3", themeColor(theme, "Text"))
		end
	end
	function c:Set(key, silent: boolean?)
		if type(key) == "string" then
			local ok, item = pcall(function()
				return Enum.KeyCode[key]
			end)
			if not ok then
				ok, item = pcall(function()
					return Enum.UserInputType[key]
				end)
			end
			key = ok and item or nil
		end
		self.Value = key
		render()
		hub:_keybindsChanged()
		if not silent and self.ChangedCallback then
			task.spawn(self.ChangedCallback, key)
		end
	end
	function c:Get()
		return self.Value
	end
	render()

	hub:_connect(chip.MouseButton1Click, function()
		listening = true
		hub._listening = true
		render()
	end)
	local function matches(input: InputObject): boolean
		local v = c.Value
		if v == nil then
			return false
		end
		if v.EnumType == Enum.KeyCode then
			return input.KeyCode == v
		end
		return input.UserInputType == v
	end
	hub:_connect(UserInputService.InputBegan, function(input)
		if not c:IsAvailable() then
			if listening then listening = false hub._listening = false render() end
			return
		end
		if listening then
			local key
			if input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
				if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
					key = nil
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
				key = input.UserInputType
			else
				return
			end
			listening = false
			task.defer(function()
				hub._listening = false
			end)
			c:Set(key)
			return
		end
		if UserInputService:GetFocusedTextBox() or not matches(input) then
			return
		end
		if c.Mode == "Toggle" then
			c.State = not c.State
			c:_emit(c.State)
		elseif c.Mode == "Hold" then
			c.State = true
			c:_emit(true)
		elseif c.Mode == "Always" then
			c:_emit(true)
		end
		hub:_keybindsChanged()
	end)
	hub:_connect(UserInputService.InputEnded, function(input)
		if c.Mode == "Hold" and c.State and matches(input) then
			c.State = false
			c:_emit(false)
			hub:_keybindsChanged()
		end
	end)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- ColorPicker
function Section:ColorPicker(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local row = self:_row(34, "Color_" .. (options.Name or ""))
	local c = self:_control("ColorPicker", options, row)
	c.Value = options.Default or rgb(255, 255, 255)
	self:_labels(row, c.Name, options.Description, 44)
	local swatch = create("TextButton", {
		Name = "Swatch",
		BackgroundColor3 = c.Value,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(36, 20),
		Text = "",
		AutoButtonColor = false,
		Parent = row,
	}, { corner(6), stroke(themeColor(theme, "FieldStroke")) })
	swatch:SetAttribute("ThemeSwatch", true)
	local h, s, v = c.Value:ToHSV()
	local update
	function c:Set(color: Color3, silent: boolean?)
		self.Value = color
		setThemed(swatch, "BackgroundColor3", color)
		if update then
			update()
		end
		if not silent then
			self:_emit(color)
		end
	end
	function c:Get()
		return self.Value
	end

	hub:_connect(swatch.MouseButton1Click, function()
		if hub._popup and hub._popup.Anchor == swatch then
			hub:_closePopup()
			return
		end
		h, s, v = c.Value:ToHSV()
		local frame = create("Frame", {
			Name = "ColorPicker",
			BackgroundColor3 = hub:GetToken("Color.PopupSurface"),
			Size = UDim2.fromOffset(212, 214),
			ZIndex = 41,
		}, { corner(hub:GetToken("Components.Popup.Radius")),
            stroke(hub:GetToken("Color.PopupBorder")), padding(10) })
		local sv = create("TextButton", {
			Name = "SaturationValue",
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			Size = UDim2.new(1, 0, 0, 140),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 42,
			Parent = frame,
		}, { corner(8) })
		create("Frame", { Name = "White", BackgroundColor3 = rgb(255, 255, 255), Size = UDim2.fromScale(1, 1), ZIndex = 43, Parent = sv }, {
			corner(8),
			create("UIGradient", { Transparency = NumberSequence.new(0, 1) }),
		})
		create("Frame", { Name = "Black", BackgroundColor3 = rgb(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 44, Parent = sv }, {
			corner(8),
			create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }),
		})
		local svKnob = create("Frame", {
			Name = "Knob",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(12, 12),
			ZIndex = 45,
			Parent = sv,
		}, { corner(6), create("UIStroke", { Color = rgb(255, 255, 255), Thickness = 2 }) })
		local hue = create("TextButton", {
			Name = "Hue",
			BackgroundColor3 = rgb(255, 255, 255),
			Position = UDim2.fromOffset(0, 150),
			Size = UDim2.new(1, 0, 0, 12),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 42,
			Parent = frame,
		}, {
			corner(6),
			create("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, rgb(255, 0, 0)),
					ColorSequenceKeypoint.new(1 / 6, rgb(255, 255, 0)),
					ColorSequenceKeypoint.new(2 / 6, rgb(0, 255, 0)),
					ColorSequenceKeypoint.new(3 / 6, rgb(0, 255, 255)),
					ColorSequenceKeypoint.new(4 / 6, rgb(0, 0, 255)),
					ColorSequenceKeypoint.new(5 / 6, rgb(255, 0, 255)),
					ColorSequenceKeypoint.new(1, rgb(255, 0, 0)),
				}),
			}),
		})
		local hueKnob = create("Frame", {
			Name = "Knob",
			BackgroundColor3 = rgb(255, 255, 255),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(6, 16),
			ZIndex = 43,
			Parent = hue,
		}, { corner(3) })
		local hex = create("TextBox", {
			Name = "Hex",
			BackgroundColor3 = themeColor(theme, "Field"),
			Position = UDim2.fromOffset(0, 172),
			Size = UDim2.new(1, -42, 0, 26),
			FontFace = MONO,
			TextSize = 12,
			TextColor3 = themeColor(theme, "Text"),
			Text = "",
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 42,
			Parent = frame,
		}, { corner(6), stroke(themeColor(theme, "FieldStroke")), padding(0, 8) })
		local preview = create("Frame", {
			Name = "Preview",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 172),
			Size = UDim2.fromOffset(34, 26),
			ZIndex = 42,
			Parent = frame,
		}, { corner(6), stroke(themeColor(theme, "FieldStroke")) })

		update = function()
			local col = c.Value
			setThemed(sv, "BackgroundColor3", Color3.fromHSV(h, 1, 1))
			svKnob.Position = UDim2.fromScale(s, 1 - v)
			hueKnob.Position = UDim2.fromScale(h, 0.5)
			setThemed(preview, "BackgroundColor3", col)
			if not hex:IsFocused() then
				hex.Text = "#" .. col:ToHex()
			end
		end
		local drag = nil
		local function apply(pos: Vector2)
			if drag == "sv" then
				local p, sz = sv.AbsolutePosition, sv.AbsoluteSize
				if sz.X <= 0 or sz.Y <= 0 then return end
				s = math.clamp((pos.X - p.X) / sz.X, 0, 1)
				v = 1 - math.clamp((pos.Y - p.Y) / sz.Y, 0, 1)
			elseif drag == "hue" then
				local p, sz = hue.AbsolutePosition, hue.AbsoluteSize
				if sz.X <= 0 then return end
				h = math.clamp((pos.X - p.X) / sz.X, 0, 0.999)
			end
			c:Set(Color3.fromHSV(h, s, v))
		end
		local function pick(area, name)
			return bindPointerDrag(hub, area, {
				Start = function(input)
					drag = name
					apply(Vector2.new(input.Position.X, input.Position.Y))
				end,
				Move = function(input) apply(Vector2.new(input.Position.X, input.Position.Y)) end,
				End = function() drag = nil end,
			}, true)
		end
		local conns = {
			pick(sv, "sv"),
			pick(hue, "hue"),
			hex.FocusLost:Connect(function()
				local ok, col = pcall(Color3.fromHex, hex.Text)
				if ok then h, s, v = col:ToHSV() c:Set(col) end
				update()
			end),
		}
		update()
		swatch:SetAttribute("ThemeSwatch", true)
		hub:_openPopup(swatch, frame, function()
			update = nil
			for _, conn in conns do
				conn:Disconnect()
			end
		end)
        hub:BindToken(frame, "BackgroundColor3", "Color.PopupSurface")
        hub:BindToken(frame:FindFirstChildOfClass("UIStroke"), "Color", "Color.PopupBorder")
        hub:BindToken(frame:FindFirstChildOfClass("UICorner"), "CornerRadius", "Components.Popup.Radius")
	end)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Label / Paragraph / info rows
function Section:Label(textValue: string)
	local theme = self.Hub.Theme
	local row = self:_row(30, "Label")
	local c = self:_control("Label", { Name = textValue }, row, textValue)
	local label = text({ Parent = row, Text = textValue, TextSize = 13, TextColor3 = themeColor(theme, "SubText"), Size = UDim2.fromScale(1, 1), TextWrapped = true })
	function c:Set(t: string)
		label.Text = t
		self.Name = t
	end
	return self.Hub:_finishRequiredControl(c)
end

function Section:Paragraph(options)
	local theme = self.Hub.Theme
	local row = self:_row(0, "Paragraph")
	row.AutomaticSize = Enum.AutomaticSize.Y
	local c = self:_control("Paragraph", { Name = options.Title }, row, options)
	local holder = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = row }, {
		list(Enum.FillDirection.Vertical, 3),
		create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 9) }),
	})
	local title = text({ Parent = holder, Text = options.Title or "", Visible = options.Title ~= nil and options.Title ~= "", TextSize = 13, FontFace = inter(Enum.FontWeight.Medium), Size = UDim2.new(1, 0, 0, 16) })
	local body = text({
		Parent = holder,
		Text = options.Content or "",
		TextSize = 12,
		TextColor3 = themeColor(theme, "SubText"),
		TextWrapped = true,
		RichText = options.RichText == true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	})
	function c:Set(newTitle: string?, content: string?)
		if newTitle then
			title.Text = newTitle
			title.Visible = newTitle ~= ""
		end
		if content then
			body.Text = content
		end
	end
	return self.Hub:_finishRequiredControl(c)
end

-- A label with a quiet value on the right. With onClick the value is a button that still
-- reads as plain text (the version line in Settings › RiftUI).
function Section:_info(name: string, value: string, onClick)
	local theme = self.Hub.Theme
	local row = self:_row(30, "Info_" .. name)
	local c = self:_control("Info", { Name = name }, row)
	text({ Parent = row, Text = name, TextSize = 13, Size = UDim2.new(0.5, 0, 1, 0) })
	local valueLabel = create(onClick and "TextButton" or "TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		Text = value,
		FontFace = MONO,
		TextSize = 12,
		TextColor3 = themeColor(theme, "SubText"),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	if onClick then
		valueLabel.AutoButtonColor = false
		self.Hub:_connect(valueLabel.MouseButton1Click, onClick)
	end
	function c:Set(v: string)
		valueLabel.Text = v
	end
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Group (dependent controls)
--[[
	A group indents a few controls under a parent toggle. It folds shut when the parent turns
	off and opens when it turns on; its header still opens it by hand so the settings can be
	prepared before switching the feature on.
]]
function Section:Group(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local hub, theme = self.Hub, self.Hub.Theme
	local parent = options.DependsOn
	local row = self:_row(0, "Group_" .. (options.Name or ""))
	row.AutomaticSize = Enum.AutomaticSize.Y
	local head = create("TextButton", { Name = "GroupHead", BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 26), Parent = row })
	local chevron = iconLabel("chevron-right", 13, theme.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Parent = head })
	local title = text({ Parent = head, Text = options.Name or "Options", TextSize = 12, FontFace = inter(Enum.FontWeight.Medium), TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -18, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	local clip = create("Frame", { Name = "GroupClip", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 0), Parent = row })
	local body = create("Frame", { Name = "GroupBody", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = clip }, {
		padding(0, 0, 4, 14), list(Enum.FillDirection.Vertical, 0),
	})
	create("Frame", { Name = "Guide", BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.fromOffset(6, 0), Size = UDim2.new(0, 1, 1, -6), Parent = clip })
	-- Pad the row so the clip's height counts toward the section.
	local spacer = create("Frame", { Name = "GroupSpace", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 0), Parent = row })

	local group = setmetatable({
		Hub = hub, Tab = self.Tab, Name = options.Name or "Options", Parent = self,
		Controls = self.Controls, Rows = body, Frame = self.Frame, Pinned = false,
		Requires = mergedRequirements(self.Requires, options.Requires),
		_internal = self._internal, _order = 0, _isGroup = true,
		_moduleCard = self._isModuleCard and self or self._moduleCard,
	}, Section)
	group.Id = self.Id .. "/" .. group.Name
	local open = false
	local searchPeek = false
	local function setHeight(h, animate)
		if animate then
			tween(clip, SETTLE, { Size = UDim2.new(1, 0, 0, h) })
			tween(spacer, SETTLE, { Size = UDim2.new(1, 0, 0, h) })
		else
			clip.Size = UDim2.new(1, 0, 0, h)
			spacer.Size = UDim2.new(1, 0, 0, h)
		end
	end
	local function contentHeight()
		return body.AbsoluteSize.Y / hub._scale
	end
	function group:SetOpen(on: boolean, instant: boolean?)
		open = on == true
		if chevron then tween(chevron, FAST, { Rotation = (open or searchPeek) and 90 or 0 }) end
		setThemed(title, "TextColor3", themeColor(theme, open and "Text" or "SubText"))
		setHeight((open or searchPeek) and contentHeight() or 0, not instant)
	end
	function group:IsOpen()
		return open
	end
	function group:_setSearchPeek(on)
		on = on == true
		if searchPeek == on then return end
		searchPeek = on
		setHeight((open or searchPeek) and contentHeight() or 0, false)
		if chevron then chevron.Rotation = (open or searchPeek) and 90 or 0 end
	end
	hub:_connect(body:GetPropertyChangedSignal("AbsoluteSize"), function()
		if open or searchPeek then setHeight(contentHeight(), false) end
	end)
	hub:_connect(head.MouseButton1Click, function() group:SetOpen(not open) end)
	hub:_connect(head.MouseEnter, function() if not open then setThemed(title, "TextColor3", themeColor(theme, "Text")) end end)
	hub:_connect(head.MouseLeave, function() if not open then setThemed(title, "TextColor3", themeColor(theme, "SubText")) end end)
	if parent and parent.Value ~= nil then
		parent._dependents = parent._dependents or {}
		table.insert(parent._dependents, function(v) group:SetOpen(v == true) end)
		open = parent.Value == true
	else
		open = options.Open == true
	end
	task.defer(function() group:SetOpen(open, true) end)
	hub:_record(self, "Group", options, group)
	return group
end

do
-- SPDX-License-Identifier: MPL-2.0
-- Optional module cards and compact information hierarchy for the original Section API.
-- Existing Section controls are reused without wrappers or replacements.
local MODULE_TONES = { Success = true, Danger = true, Warning = true, Accent = true,
    Text = true, SubText = true, Muted = true }

local function moduleTone(value)
    return MODULE_TONES[value] and value or "SubText"
end

local function moduleString(value)
    if value == nil then return "—" end
    return tostring(value)
end

local function moduleCopy(value)
    return type(value) == "table" and table.clone(value) or value
end

-- Legacy versions stored only the collapsed (true) preference. Use explicit
-- strings now so a user can persist an expansion even when Collapsed=true.
local function moduleIsExpanded(saved, initiallyCollapsed)
    if saved == "expanded" or saved == false then return true end
    if saved == "collapsed" or saved == true then return false end
    return not initiallyCollapsed
end

local function moduleInfoIndex(items)
    local index = {}
    for i, item in items do index[item.Key] = i end
    return index
end

local function moduleInfoSnapshot(items)
    local out = {}
    for i, item in items do out[i] = table.clone(item) end
    return out
end

function Section:ModuleCard(options)
    options = type(options) == "table" and options or { Name = moduleString(options) }
    local hub, theme = self.Hub, self.Hub.Theme
    local name = options.Name or "Module"
    local id = self.Id .. "/module/" .. moduleString(options.Id or name)
    local hasToggle = options.Flag ~= nil or options.Toggle == true
    local canCollapse = options.Collapsible ~= false
    local canFavorite = options.Favoritable ~= false
    local originalOrder = self._order + 1
    local saved = hub.SetupData or {}
    local savedFold = nil
    if type(saved.ModuleCards) == "table" then savedFold = saved.ModuleCards[id] end
    local savedFavorite = type(saved.ModuleFavorites) == "table" and saved.ModuleFavorites[id]
    local row = self:_row(0, "ModuleCard_" .. name)
    row.AutomaticSize = Enum.AutomaticSize.Y
    local surface = create("Frame", {
        Name = "ModuleSurface", BackgroundColor3 = themeColor(theme, "Tile"),
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
    }, { corner(10), stroke(themeColor(theme, "TileStroke"), 1, .32),
        padding(5, 6, 5, 6),
        list(Enum.FillDirection.Vertical, 1) })
    -- Reference layout: circular leading icon, stacked title/summary, and
    -- right-side chevron/star above the switch. No visible status chips.
    local moduleTokens = hub:GetComponentTokens("ModuleCard")
    local iconSize = moduleTokens.IconSize
    local function minimumHeaderHeight()
        if hasToggle then return moduleTokens.HeaderHeight end
        if options.Icon then
            return math.max(moduleTokens.HeaderHeight - 14, iconSize + 20)
        end
        return math.max(70, moduleTokens.HeaderHeight - 22)
    end
    local baseHeight = minimumHeaderHeight()
    -- Top-row action and lower toggle straddle the same vertical center as
    -- the icon and text. With no toggle, the only action row is centered.
    local actionOffset = hasToggle and 21 or 0
    local actionInset = canCollapse and canFavorite and 88
        or ((canCollapse or canFavorite or hasToggle) and 46 or 8)
    -- Upper chevron/star need their gutter for the title, but the summary
    -- can extend below them up to the lower switch hit target.
    local descriptionInset = hasToggle and 46 or actionInset
    local head = create("TextButton", {
        Name = "ModuleHead", BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Size = UDim2.new(1, 0, 0, baseHeight),
        ZIndex = 2, Parent = surface,
    })
    local titleX = 8
    local iconShell, icon
    if options.Icon then
        iconShell = create("Frame", {
            Name = "ModuleIcon", Parent = head, BorderSizePixel = 0,
            BackgroundColor3 = themeColor(theme, "Accent"),
            BackgroundTransparency = .70,
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(0, math.floor(iconSize / 2) + 4, .5, 0),
            Size = UDim2.fromOffset(iconSize, iconSize), ZIndex = 3,
        }, { corner(100) })
        icon = iconLabel(options.Icon, moduleTokens.GlyphSize, theme.Text, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            ZIndex = 4, Parent = iconShell,
        })
        if icon then
            titleX = iconSize + 11
        else
            iconShell:Destroy()
            iconShell = nil
        end
    end
    local title = text({
        Parent = head, Name = "ModuleTitle", Text = name,
        FontFace = inter(Enum.FontWeight[hub:GetToken("Typography.ModuleTitle.Weight")]),
        TextSize = hub:GetToken("Typography.ModuleTitle.Size"),
        TextColor3 = hub:GetToken("Color.TextPrimary"),
        Position = UDim2.fromOffset(titleX, 23),
        Size = UDim2.new(1, -titleX - actionInset, 0, 22),
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3,
    })
    -- The star is on the outside, the chevron immediately to its left.
    -- Invisible 40px targets preserve touch ergonomics without boxed icons.
    local chevron, expandButton
    if canCollapse then
        expandButton = create("TextButton", {
            Name = "ExpandAction", BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, canFavorite and -46 or -4, .5, -actionOffset),
            Size = UDim2.fromOffset(40, 40), ZIndex = 5, Parent = head,
        })
        chevron = iconLabel("chevron-up", 20, theme.Text, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            ZIndex = 6, Parent = expandButton,
        })
    end
    local favorite, favoriteIcon
    if canFavorite then
        favorite = create("TextButton", {
            Name = "Favorite", BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -4, .5, -actionOffset),
            Size = UDim2.fromOffset(40, 40), ZIndex = 5, Parent = head,
        })
        favoriteIcon = iconLabel("star", 21, theme.Muted, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            Parent = favorite, ZIndex = 6,
        })
    end
    local toggle, toggleTrack, knob, togglePress
    if hasToggle then
        toggle = create("TextButton", {
            Name = "ModuleSwitch", BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, .5),
            Position = UDim2.new(1, -4, .5, actionOffset),
            Size = UDim2.fromOffset(44, 44), ZIndex = 5, Parent = head,
        })
        togglePress = create("UIScale", { Name = "PressFeedback", Scale = 1, Parent = toggle })
        toggleTrack = create("Frame", {
            Name = "ModuleSwitchTrack", BackgroundColor3 = themeColor(theme, "Field"),
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromOffset(34, 20), ZIndex = 6, Parent = toggle,
        }, { corner(12), stroke(themeColor(theme, "FieldStroke")) })
        knob = create("Frame", {
            Name = "ModuleThumb", BackgroundColor3 = themeColor(theme, "Text"),
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0, .5),
            Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(14, 14),
            ZIndex = 7, Parent = toggleTrack,
        }, { corner(9) })
    end
    -- Description sits directly below the title; actions occupy a separate
    -- right column, not a full-width action row above the summary.
    local description = text({
        Parent = head, Name = "ModuleSummary",
        Text = options.Description or options.Summary or "",
        TextSize = hub:GetToken("Typography.ModuleSummary.Size"),
        TextColor3 = hub:GetToken("Color.TextSecondary"),
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(titleX, 49),
        Size = UDim2.new(1, -titleX - descriptionInset, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 3,
    })
    hub:BindToken(title, "TextSize", "Typography.ModuleTitle.Size")
    hub:BindToken(description, "TextSize", "Typography.ModuleSummary.Size")
    hub:BindToken(title, "TextColor3", "Color.TextPrimary")
    hub:BindToken(description, "TextColor3", "Color.TextSecondary")
    local function refreshHeaderLayout()
        if not head.Parent then return end
        local scale = math.max(hub._scale or 1, .01)
        local hasSummary = description.Text ~= ""
        description.Visible = hasSummary
        local titleHeight = math.max(22, math.ceil(title.AbsoluteSize.Y / scale),
            math.ceil(title.TextBounds.Y / scale))
        local descHeight = hasSummary and math.max(20,
            math.ceil(description.AbsoluteSize.Y / scale),
            math.ceil(description.TextBounds.Y / scale)) or 0
        local gap = hasSummary and 4 or 0
        local textHeight = titleHeight + gap + descHeight
        local desired = math.max(baseHeight, textHeight + 20)
        if hasToggle and hasSummary then
            -- The summary uses the right-side gutter below the upper
            -- chevron/star. Ensure its first line starts below their 40px
            -- touch targets even for a multi-line summary; leave 10px below.
            desired = math.max(desired, 2 * (descHeight + 11))
        end
        if head.Size.Y.Offset ~= desired then
            head.Size = UDim2.new(1, 0, 0, desired)
        end
        -- Center the complete title+description block against the circular
        -- icon and the midpoint between the upper actions and lower toggle.
        local top = math.floor((desired - textHeight) / 2)
        local summaryTop = top + titleHeight + gap
        if hasToggle and hasSummary then
            summaryTop = math.max(summaryTop,
                math.ceil(desired / 2 - actionOffset + 22))
        end
        if title.Position.Y.Offset ~= top or title.Position.X.Offset ~= titleX then
            title.Position = UDim2.fromOffset(titleX, top)
        end
        if description.Position.Y.Offset ~= summaryTop or description.Position.X.Offset ~= titleX then
            description.Position = UDim2.fromOffset(titleX, summaryTop)
        end
    end
    hub:_connect(description:GetPropertyChangedSignal("AbsoluteSize"), refreshHeaderLayout)
    hub:_connect(description:GetPropertyChangedSignal("TextBounds"), refreshHeaderLayout)
    hub:_connect(title:GetPropertyChangedSignal("AbsoluteSize"), refreshHeaderLayout)
    hub:_connect(title:GetPropertyChangedSignal("TextBounds"), refreshHeaderLayout)
    -- Recompute coupled geometry when the public ModuleCard size tokens are
    -- overridden; existing cards update without rebuilding their controls.
    local geometryWatcher = hub:WatchDesignTokens(function()
        moduleTokens = hub:GetComponentTokens("ModuleCard")
        iconSize = moduleTokens.IconSize
        baseHeight = minimumHeaderHeight()
        if iconShell then
            iconShell.Size = UDim2.fromOffset(iconSize, iconSize)
            iconShell.Position = UDim2.new(0, math.floor(iconSize / 2) + 4, .5, 0)
            if icon then
                icon.Size = UDim2.fromOffset(moduleTokens.GlyphSize, moduleTokens.GlyphSize)
            end
            titleX = iconSize + 11
        end
        title.Size = UDim2.new(1, -titleX - actionInset, 0, 22)
        description.Size = UDim2.new(1, -titleX - descriptionInset, 0, 20)
        refreshHeaderLayout()
    end)
    -- Use a native Frame for text: CanvasGroup composites glyphs to a texture,
    -- reducing clarity on mobile devices and with nested panels.
    local clip = create("Frame", {
        Name = "ModuleClip", BackgroundTransparency = 1, Visible = false,
        ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 2, Parent = surface,
    })
    local body = create("Frame", {
        Name = "ModuleBody", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = clip,
    }, { padding(2, 3, 3, 3), list(Enum.FillDirection.Vertical, 1) })
    -- The shared locked overlay covers the entire row (including heading and
    -- toggle), unlike the legacy body-only lock panel.
    local parentCard = self._isModuleCard and self or self._moduleCard
    local card = setmetatable({
        Type = "ModuleCard", Name = name, Id = id,
        Hub = hub, Tab = self.Tab, Section = self, Parent = self,
        Rows = body, Frame = row, Surface = surface, Head = head,
        Controls = self.Controls, Requires = mergedRequirements(self.Requires, options.Requires),
        _internal = self._internal, _order = 0, _isModuleCard = true,
        _parentCard = parentCard, _moduleControls = {}, _default = options.Default == true,
        Flag = options.Flag, Value = options.Default == true,
        _expanded = not canCollapse or moduleIsExpanded(savedFold, options.Collapsed == true),
        _favorite = savedFavorite == true,
        _locked = options.Locked == true or options.State == "Locked", _blocked = false, _hidden = false,
        _lockReason = options.LockReason,
        _lockOptions = type(options.Lock) == "table" and table.clone(options.Lock) or {
            Title = options.LockTitle, Details = options.LockDetails,
            Actions = options.LockActions,
        },
        _inheritedBlocked = false,
        _searchPeek = false, _animating = false,
        _dataObservers = {}, _dataSubscriptions = {},
        _summary = options.Description or options.Summary or "",
        _status = options.Status or "", _tone = moduleTone(options.Tone),
    }, Section)
    card._moduleCard = parentCard
    card._hasToggle = hasToggle
    card._canCollapse = canCollapse
    card._canFavorite = canFavorite
    local motionKey = "module-card:" .. id
    local callbacks = {}

    function card:OnDataEvent(event, fn)
        assert(type(event) == "string" and event ~= "", "module event name required")
        assert(type(fn) == "function", "module event callback required")
        assert(not self._disposed and not hub._destroyed, "module card destroyed")
        local listeners = self._dataObservers[event] or {}
        self._dataObservers[event] = listeners
        table.insert(listeners, fn)
        local sub = { Connected = true }
        self._dataSubscriptions[sub] = true
        hub._directDataSubscriptions = hub._directDataSubscriptions or {}
        hub._directDataSubscriptions[sub] = true
        function sub:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            local at = table.find(listeners, fn)
            if at then table.remove(listeners, at) end
            card._dataSubscriptions[self] = nil
            if hub._directDataSubscriptions then hub._directDataSubscriptions[self] = nil end
        end
        return sub
    end
    function card:_dataEvent(event, payload)
        if self._disposed or hub._destroyed then return end
        for _, fn in table.clone(self._dataObservers[event] or {}) do
            local ok, err = xpcall(fn, debug.traceback, payload, self)
            if not ok then warn("[RelaxUI] module event: " .. tostring(err)) end
        end
    end
    function card:GetStatus() return { Status = self._status, Tone = self._tone } end
    function card:GetSummary() return self._summary end
    local function saveMap(field, value)
        local map = table.clone(type(hub.SetupData and hub.SetupData[field]) == "table"
            and hub.SetupData[field] or {})
        map[id] = value
        hub:_savePref(field, map)
    end
    local function blocked()
        return card._locked or card._blocked or card._inheritedBlocked
    end
    function card:IsAvailable()
        if self._locked then return false, self._lockReason or "该模块已锁定" end
        if self._blocked or self._inheritedBlocked then
            return false, options.DependsReason or "需要先启用依赖模块"
        end
        return hub:CanUse(self.Requires)
    end
    function card:GetAvailability()
        local ok, reason = self:IsAvailable()
        return ok and "Available" or "Locked", reason
    end
    function card:SetAvailability(state, reason, lockOptions)
        assert(state == "Available" or state == "Locked", "state must be Available or Locked")
        return self:SetLocked(state == "Locked", reason, lockOptions)
    end
    function card:SetLockActions(actions)
        assert(type(actions) == "table", "lock actions must be a table")
        self._lockOptions = self._lockOptions or {}
        self._lockOptions.Actions = table.clone(actions)
        return self
    end
    function card:ShowLockReason()
        if self:IsAvailable() then return nil end
        return hub:_openLockedReason(self)
    end
    local function paintBlock(animate)
        hub:_syncLockOverlay(card)
        if not toggle then return end
        local trackColor = themeColor(theme, card.Value and "Accent" or "Field")
        local thumbColor = themeColor(theme, card.Value and "AccentText" or "Text")
        local thumbPosition = UDim2.new(0, card.Value and 17 or 3, .5, 0)
        if animate then
            Motion.transition(hub, motionKey .. ":switch",
                card.Value and "on" or "off", {
                    { Target = toggleTrack, Goals = { BackgroundColor3 = trackColor } },
                    { Target = knob, Goals = { BackgroundColor3 = thumbColor,
                        Position = thumbPosition } },
                }, Motion.Presets.Micro)
        else
            Motion.cancel(hub, motionKey .. ":switch")
            setThemed(toggleTrack, "BackgroundColor3", trackColor)
            setThemed(knob, "BackgroundColor3", thumbColor)
            knob.Position = thumbPosition
        end
    end
    local function notifyDependents()
        for _, fn in card._dependents or {} do
            local ok, err = pcall(fn, card.Value)
            if not ok then warn("[RelaxUI] module dependent: " .. tostring(err)) end
        end
    end
    function card:Set(value, silent)
        if not self._hasToggle or not self:IsAvailable() then return false end
        value = value == true
        if self.Value == value then return true end
        self.Value = value
        paintBlock(not silent)
        -- Structural dependencies must update even on silent config restore.
        notifyDependents()
        for _, callback in callbacks do
            task.spawn(function()
                if not hub._destroyed and not card._disposed then
                    local ok, err = pcall(callback, value)
                    if not ok then warn("[RelaxUI] module observer: " .. tostring(err)) end
                end
            end)
        end
        if not silent then
            self:_dataEvent("Value", value)
            hub:PlayUISound(value and "ToggleOn" or "ToggleOff")
            if type(options.Callback) == "function" then
                task.spawn(function()
                    if not hub._destroyed and not card._disposed then
                        local ok, err = pcall(options.Callback, value)
                        if not ok then warn("[RelaxUI] module callback: " .. tostring(err)) end
                    end
                end)
            end
        end
        return true
    end
    function card:Get() return self.Value end
    function card:OnChanged(fn)
        if type(fn) == "function" then table.insert(callbacks, fn) end
        return self
    end
    function card:OffChanged(fn)
        local i = table.find(callbacks, fn)
        if not i then return false end
        table.remove(callbacks, i)
        return true
    end
    function card:SetLocked(on, reason, lockOptions)
        local old = self._locked
        self._locked = on == true
        if type(reason) == "table" then
            lockOptions = reason
            reason = reason.Reason
        end
        if reason ~= nil then self._lockReason = tostring(reason) end
        if type(lockOptions) == "table" then self._lockOptions = table.clone(lockOptions) end
        paintBlock()
        if old ~= self._locked then
            notifyDependents()
            self:_dataEvent("Locked", self._locked)
        end
    end
    function card:IsLocked() return not self:IsAvailable() end
    function card:SetSummary(value)
        local summary = moduleString(value)
        if self._summary == summary then return end
        self._summary = summary
        description.Text = summary
        refreshHeaderLayout()
        self:_dataEvent("Summary", summary)
    end
    function card:SetStatus(status, tone)
        local nextStatus = status and tostring(status) or ""
        -- Text-only status changes retain the existing semantic color role.
        local nextTone = tone == nil and self._tone or moduleTone(tone)
        if self._status == nextStatus and self._tone == nextTone then return end
        -- Keep status in the public data/event API, never render a badge.
        self._status, self._tone = nextStatus, nextTone
        self:_dataEvent("Status", self:GetStatus())
    end
    local function height()
        return math.max(0, body.AbsoluteSize.Y / math.max(hub._scale, .01))
    end
    local function effective() return not canCollapse or card._expanded or card._searchPeek end
    local function resize(animate)
        local open = effective()
        local target = open and height() or 0
        if chevron then
            if animate then
                Motion.play(hub, motionKey .. ":arrow", chevron,
                    { Rotation = open and 0 or 180 }, Motion.Presets.Micro)
            else
                Motion.cancel(hub, motionKey .. ":arrow")
                chevron.Rotation = open and 0 or 180
            end
        end
        if animate then
            card._animating = true
            local targetSize = UDim2.new(1, 0, 0, target)
            -- Keep the native clip in the UIListLayout until its closing
            -- height finishes. Hiding it now snaps the row shut immediately.
            -- ClipsDescendants trims controls without rasterizing their text.
            clip.Visible = true
            Motion.play(hub, motionKey, clip, { Size = targetSize },
                Motion.Presets.Control, function()
                if hub._destroyed or not clip.Parent then return end
                card._animating = false
                clip.Size = UDim2.new(1, 0, 0, effective() and height() or 0)
                clip.Visible = effective()
            end)
        else
            Motion.cancel(hub, motionKey)
            card._animating = false
            clip.Size = UDim2.new(1, 0, 0, target)
            clip.Visible = open
        end
    end
    function card:SetExpanded(on, instant)
        if not canCollapse then return end
        on = on == true
        if self._expanded == on then return end
        self._expanded = on
        saveMap("ModuleCards", on and "expanded" or "collapsed")
        resize(not instant)
        self:_dataEvent("Expanded", on)
    end
    function card:IsExpanded() return effective() end
    function card:GetExpandedPreference() return self._expanded end
    function card:_setSearchPeek(on)
        on = on == true
        if self._searchPeek == on then return end
        self._searchPeek = on
        resize(false)
    end
    function card:SetFavorite(on)
        if not canFavorite then return end
        on = on == true
        if self._favorite == on then return end
        self._favorite = on
        row.LayoutOrder = self._favorite and -1000 + originalOrder or originalOrder
        if favoriteIcon then
            Motion.play(hub, motionKey .. ":favorite", favoriteIcon,
                { ImageColor3 = self._favorite and Color3.fromRGB(255, 211, 65)
                    or themeColor(theme, "Muted") }, Motion.Presets.Micro)
        end
        saveMap("ModuleFavorites", self._favorite)
        self:_dataEvent("Favorite", self._favorite)
    end
    function card:IsFavorite() return self._favorite end
    function card:SetVisible(on)
        self._hidden = on == false
        row.Visible = not self._hidden and not self._dependencyHidden
        self:_dataEvent("Visibility", row.Visible)
    end
    function card:Reset()
        if self._hasToggle then
            local locked, dep, inherited = self._locked, self._blocked, self._inheritedBlocked
            self._locked, self._blocked, self._inheritedBlocked = false, false, false
            self:Set(self._default, true)
            self._locked, self._blocked, self._inheritedBlocked = locked, dep, inherited
            paintBlock()
            notifyDependents()
        end
        for _, control in self._moduleControls do
            if control.Type == "ModuleCard" then
                control:Reset()
            elseif control.DefaultValue ~= nil and type(control.Set) == "function" then
                pcall(control.Set, control, moduleCopy(control.DefaultValue), true)
            end
        end
        if canCollapse then self:SetExpanded(options.Collapsed ~= true) end
    end
    function card:SetDependencyBlocked(on)
        local blockedNow = on == true
        if self._blocked == blockedNow then return end
        self._blocked = blockedNow
        paintBlock()
        notifyDependents()
    end

    if options.Flag then
        assert(type(options.Flag) == "string", "ModuleCard.Flag must be a string")
        RiftUI.Flags[options.Flag] = card
    end
    -- A card is a real search/command entity while its nested controls still
    -- belong to the original Section.  This preserves Flags and existing APIs.
    local function bindDependency(dep)
        if not dep then return end
        local control, equals, behavior
        if type(dep) == "table" and dep.Control == nil and dep.Flag == nil and dep.Get then
            control, equals, behavior = dep, true, "Disable"
        elseif type(dep) == "table" then
            control = dep.Control or (dep.Flag and RiftUI.Flags[dep.Flag])
            equals = dep.Equals
            if equals == nil then equals = true end
            behavior = dep.Behavior or "Disable"
        end
        if not control or type(control.Get) ~= "function" then return end
        local function apply(value)
            local active = value == equals
            if behavior == "Hide" then
                row.Visible = active and not card._hidden
                card._dependencyHidden = not active
            else
                card:SetDependencyBlocked(not active)
            end
        end
        apply(control:Get())
        if control.Type == "ModuleCard" or control.Type == "Toggle" then
            -- Core dependency state must update synchronously, including
            -- config restores performed with silent=true.
            control._dependents = control._dependents or {}
            table.insert(control._dependents, apply)
            hub:_connect(row.Destroying, function()
                local at = table.find(control._dependents or {}, apply)
                if at then table.remove(control._dependents, at) end
            end)
        elseif type(control.OnChanged) == "function" then
            control:OnChanged(apply)
            if type(control.OffChanged) == "function" then
                hub:_connect(row.Destroying, function() control:OffChanged(apply) end)
            end
        end
    end
    -- Optional nested inheritance. No values are changed: inactive or locked
    -- ancestors simply prevent touch through the existing lock overlay.
    if parentCard and options.InheritParentState == true then
        local function syncParentState()
            local nextBlocked = (parentCard._hasToggle and not parentCard:Get())
                or parentCard:IsLocked()
            nextBlocked = nextBlocked == true
            if card._inheritedBlocked ~= nextBlocked then
                card._inheritedBlocked = nextBlocked
                paintBlock()
                notifyDependents()
            end
        end
        parentCard._dependents = parentCard._dependents or {}
        table.insert(parentCard._dependents, syncParentState)
        syncParentState()
        hub:_connect(row.Destroying, function()
            local at = table.find(parentCard._dependents or {}, syncParentState)
            if at then table.remove(parentCard._dependents, at) end
        end)
    end
    bindDependency(options.DependsOn)
    hub:_connect(body:GetPropertyChangedSignal("AbsoluteSize"), function()
        if not hub._destroyed and not card._animating and effective() then
            clip.Size = UDim2.new(1, 0, 0, height())
        end
    end)
    hub:_connect(head.MouseButton1Click, function()
        if canCollapse then card:SetExpanded(not card._expanded) end
    end)
    if expandButton then
        hub:_connect(expandButton.MouseButton1Click, function()
            card:SetExpanded(not card._expanded)
        end)
    end
    if favorite then
        hub:_connect(favorite.MouseButton1Click, function()
            card:SetFavorite(not card._favorite)
        end)
    end
    if toggle then
        hub:_connect(toggle.MouseButton1Down, function()
            Motion.play(hub, motionKey .. ":press", togglePress, { Scale = .94 }, FAST)
        end)
        local function releaseTouch()
            Motion.play(hub, motionKey .. ":press", togglePress, { Scale = 1 }, FAST)
        end
        hub:_connect(toggle.MouseButton1Up, releaseTouch)
        hub:_connect(toggle.MouseLeave, releaseTouch)
        hub:_connect(toggle.InputEnded, function(input)
            if isPointer(input) then releaseTouch() end
        end)
        hub:_connect(toggle.MouseButton1Click, function()
            releaseTouch()
            card:Set(not card.Value)
        end)
    end
    card:SetStatus(options.Status, options.Tone)
    refreshHeaderLayout()
    if #card.Requires > 0 then table.insert(hub._requiredControls, card) end
    paintBlock(false)
    if card._favorite then
        row.LayoutOrder = -1000 + originalOrder
        if favoriteIcon then
            setThemed(favoriteIcon, "ImageColor3", Color3.fromRGB(255, 211, 65))
        end
    end
    if chevron then chevron.Rotation = effective() and 0 or 180 end
    resize(false)
    task.defer(function()
        if not hub._destroyed and row.Parent and not card._animating then resize(false) end
    end)
    table.insert(self.Controls, card)
    if parentCard then table.insert(parentCard._moduleControls, card) end
    hub:BindToken(surface, "BackgroundColor3", "Color.Surface2")
    hub:BindToken(surface:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
    hub:BindToken(surface:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.M")
    -- The module uses dedicated compact insets, not Spacing.S (8px):
    -- rebinding those tokens here silently inflated the visible card height.
    -- Keep the local 5/6px padding while colors, fonts and radius stay themed.
    -- Keep dedicated ModuleTitle/ModuleSummary typography bindings above.
    -- Generic Body/Meta overrides silently undid the component token roles.
    hub:_connect(row.Destroying, function()
        if geometryWatcher then geometryWatcher:Disconnect() end
        Motion.cancel(hub, motionKey)
        Motion.cancel(hub, motionKey .. ":arrow")
        Motion.cancel(hub, motionKey .. ":press")
        Motion.cancel(hub, motionKey .. ":switch")
        Motion.cancel(hub, motionKey .. ":favorite")
        card._disposed = true
        table.clear(callbacks)
        for sub in table.clone(card._dataSubscriptions) do sub:Disconnect() end
        table.clear(card._dataSubscriptions)
        table.clear(card._dataObservers)
        hub:_dataDetachControl(card)
    end)
    hub:_record(self, "ModuleCard", options, card)
    return card
end

local function infoNormalize(items)
    local out, seen = {}, {}
    for i, item in type(items) == "table" and items or {} do
        if type(item) == "table" then
            local key = moduleString(item.Key or item.Id or item.Name or item.Label or i)
            assert(not seen[key], "duplicate information key: " .. key)
            seen[key] = true
            table.insert(out, {
                Key = key, Label = moduleString(item.Label or item.Name or key),
                Value = moduleString(item.Value), Detail = item.Detail or item.Hint or "",
                Tone = moduleTone(item.Tone),
            })
        else
            local key = tostring(i)
            assert(not seen[key], "duplicate information key: " .. key)
            seen[key] = true
            table.insert(out, {
                Key = key, Label = key, Value = moduleString(item),
                Detail = "", Tone = "Text",
            })
        end
    end
    return out
end

-- Snapshots and stable reordering support live dashboards without reallocating cells.
local function infoPublish(control, operation, key)
    -- Avoid constructing full dashboard snapshots when no Data observers exist.
    local listeners = control._dataObservers and control._dataObservers.Data
    if not listeners or #listeners == 0 or control._disposed then return end
    local payload = { Operation = operation, Key = key }
    if key ~= nil then
        payload.Item = control:GetItem(key)
    else
        payload.Items = control:Get()
    end
    control:_dataEvent("Data", payload)
end

local function infoReorder(items, order)
    if type(order) ~= "table" or #order ~= #items then return nil, "order length mismatch" end
    local index = moduleInfoIndex(items)
    local seen, result = {}, {}
    for _, id in order do
        local key = tostring(id)
        local at = index[key]
        if not at or seen[key] then return nil, "unknown or duplicate information key: " .. key end
        seen[key] = true
        table.insert(result, items[at])
    end
    return result
end

function Section:InfoGrid(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local row = self:_row(0, "InfoGrid_" .. (options.Name or "Metrics"))
    local control = self:_control("InfoGrid", options, row)
    control.Items = {}
    local indexByKey = {}
    local captionH = options.Name and 22 or 0
    local caption
    if options.Name then
        caption = text({
            Parent = row, Text = options.Name, FontFace = inter(Enum.FontWeight.SemiBold),
            TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
            Size = UDim2.new(1, 0, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd,
        })
    end
    local grid = create("Frame", {
        Name = "MetricGrid", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, captionH),
        Size = UDim2.new(1, 0, 0, 0), Parent = row,
    })
    local tiles = {}
    local cellH, gap = 66, 6
    local function layout()
        if hub._destroyed then return end
        local width = grid.AbsoluteSize.X / math.max(hub._scale, .01)
        local maxColumns = math.clamp(math.floor(tonumber(options.Columns) or 2), 1, 4)
        local minWidth = math.max(74, tonumber(options.MinCellWidth) or 90)
        local cols = math.clamp(math.floor((width + gap) / (minWidth + gap)), 1, maxColumns)
        for i, tile in tiles do
            local col = (i - 1) % cols
            local nrow = math.floor((i - 1) / cols)
            if options.FillLastRow ~= false and cols > 1 and i == #tiles and col == 0 then
                tile.Position = UDim2.fromOffset(0, nrow * (cellH + gap))
                tile.Size = UDim2.new(1, 0, 0, cellH)
            else
                tile.Position = UDim2.new(col / cols, col * gap / cols, 0, nrow * (cellH + gap))
                tile.Size = UDim2.new(1 / cols, -(cols - 1) * gap / cols, 0, cellH)
            end
        end
        local count = math.ceil(#tiles / cols)
        local height = count > 0 and count * cellH + (count - 1) * gap or 0
        grid.Size = UDim2.new(1, 0, 0, height)
        row.Size = UDim2.new(1, 0, 0, captionH + height + (height > 0 and 4 or 0))
    end
    local function rebuild()
        -- Keyed reconciliation preserves the actual metric tile across inserts,
        -- removals and reorder operations (without rebuilding live animations).
        local previous = {}
        for _, tile in tiles do previous[tile.Name] = tile end
        local arranged = {}
        for _, item in control.Items do
            local tileName = "Metric_" .. item.Key
            local tile = previous[tileName]
            previous[tileName] = nil
            if not tile then
                tile = create("Frame", {
                    Name = tileName, BackgroundColor3 = themeColor(theme, "Section"),
                    BackgroundTransparency = .1, Parent = grid,
                }, { corner(8), stroke(themeColor(theme, "SectionStroke"), 1) })
                text({ Parent = tile, Name = "Label", Text = item.Label, TextSize = 10,
                    TextColor3 = themeColor(theme, "Muted"), Position = UDim2.fromOffset(9, 6),
                    Size = UDim2.new(1, -18, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
                text({ Parent = tile, Name = "Value", Text = item.Value,
                    FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 16,
                    TextColor3 = themeColor(theme, item.Tone), Position = UDim2.fromOffset(9, 23),
                    Size = UDim2.new(1, -18, 0, 22), TextTruncate = Enum.TextTruncate.AtEnd })
                text({ Parent = tile, Name = "Hint", Text = tostring(item.Detail),
                    TextSize = 10, TextColor3 = themeColor(theme, "Muted"),
                    Position = UDim2.fromOffset(9, 46),
                    Size = UDim2.new(1, -18, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
                hub:BindToken(tile, "BackgroundColor3", "Color.Surface1")
                hub:BindToken(tile:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
            end
            local label, value, hint = tile:FindFirstChild("Label"), tile:FindFirstChild("Value"), tile:FindFirstChild("Hint")
            if label and label.Text ~= item.Label then label.Text = item.Label end
            if value then
                if value.Text ~= item.Value then value.Text = item.Value end
                setThemed(value, "TextColor3", themeColor(theme, item.Tone))
            end
            if hint and hint.Text ~= tostring(item.Detail) then hint.Text = tostring(item.Detail) end
            table.insert(arranged, tile)
        end
        for _, tile in previous do tile:Destroy() end
        tiles = arranged
        layout()
    end
    -- Reuse tiles when keys/order are unchanged: live telemetry should not
    -- rebuild every GuiObject or trigger a layout pass for each value refresh.
    function control:Set(items, silent)
        local nextItems = infoNormalize(items)
        local stable = #nextItems == #self.Items
        if stable then
            for i, item in nextItems do
                if self.Items[i].Key ~= item.Key then stable = false; break end
            end
        end
        self.Items = nextItems
        indexByKey = moduleInfoIndex(nextItems)
        if stable then
            for i, item in nextItems do
                local tile = tiles[i]
                if tile then
                    local label = tile:FindFirstChild("Label")
                    local readout = tile:FindFirstChild("Value")
                    local hint = tile:FindFirstChild("Hint")
                    if label and label.Text ~= item.Label then label.Text = item.Label end
                    if readout then
                        if readout.Text ~= item.Value then readout.Text = item.Value end
                        setThemed(readout, "TextColor3", themeColor(theme, item.Tone))
                    end
                    if hint and hint.Text ~= tostring(item.Detail) then
                        hint.Text = tostring(item.Detail)
                    end
                end
            end
        else
            rebuild()
        end
        if not silent then infoPublish(self, "Set") end
        return true
    end
    function control:Update(key, value, tone, silent)
        local i = indexByKey[tostring(key)]
        local item = i and self.Items[i]
        if not item then return false end
        local nextValue = moduleString(value)
        if item.Value ~= nextValue then
            item.Value = nextValue
            local tile = tiles[i]
            local readout = tile and tile:FindFirstChild("Value")
            if readout then readout.Text = nextValue end
        end
        if tone and item.Tone ~= moduleTone(tone) then
            item.Tone = moduleTone(tone)
            local tile = tiles[i]
            local readout = tile and tile:FindFirstChild("Value")
            if readout then setThemed(readout, "TextColor3", themeColor(theme, item.Tone)) end
        end
        if not silent then infoPublish(self, "Update", tostring(key)) end
        return true
    end
    -- Strict batching validates every key before mutating any row.
    -- Default mode retains the old best-effort count-based contract.
    function control:UpdateMany(values, strict)
        local requireAll = strict == true or (type(strict) == "table" and strict.Strict == true)
        local silent = type(strict) == "table" and strict.Silent == true
        if type(values) ~= "table" then
            if requireAll then return false, "updates must be a table" end
            return 0
        end
        if requireAll then
            for key, update in values do
                if not indexByKey[tostring(key)] then
                    return false, "unknown information key: " .. tostring(key)
                end
                if type(update) == "table" and update.Value == nil then
                    return false, "batch entry requires Value: " .. tostring(key)
                end
            end
        end
        local count = 0
        for key, update in values do
            local ok
            if type(update) == "table" and update.Value ~= nil then
                ok = self:Update(key, update.Value, update.Tone, true)
            else
                ok = self:Update(key, update, nil, true)
            end
            if ok then count += 1 end
        end
        if count > 0 and not silent then infoPublish(self, "Batch") end
        return count
    end
    function control:UpdateManyStrict(values)
        return self:UpdateMany(values, true)
    end
    function control:Upsert(item)
        assert(type(item) == "table" and item.Key ~= nil, "InfoGrid:Upsert needs a Key")
        local entry = infoNormalize({ item })[1]
        local current = indexByKey[entry.Key]
        local nextItems = moduleInfoSnapshot(self.Items)
        if current then nextItems[current] = entry else table.insert(nextItems, entry) end
        self:Set(nextItems, true)
        infoPublish(self, "Upsert", entry.Key)
        return true
    end
    function control:Remove(key)
        local i = indexByKey[tostring(key)]
        if not i then return false end
        local nextItems = moduleInfoSnapshot(self.Items)
        table.remove(nextItems, i)
        self:Set(nextItems, true)
        infoPublish(self, "Remove", tostring(key))
        return true
    end
    function control:Clear() return self:Set({}) end
    function control:Get() return moduleInfoSnapshot(self.Items) end
    function control:GetItem(key)
        local index = indexByKey[tostring(key)]
        return index and table.clone(self.Items[index]) or nil
    end
    function control:SetOrder(order)
        local arranged, err = infoReorder(self.Items, order)
        if not arranged then return false, err end
        local previous = {}
        for i, item in self.Items do previous[item.Key] = tiles[i] end
        self.Items = arranged
        indexByKey = moduleInfoIndex(arranged)
        local reordered = {}
        for i, item in arranged do reordered[i] = previous[item.Key] end
        tiles = reordered
        layout()
        infoPublish(self, "Order")
        return true
    end
    hub:_connect(row.Destroying, function() hub:_dataDetachControl(control) end)
    hub:_connect(grid:GetPropertyChangedSignal("AbsoluteSize"), function()
        if row.Parent then layout() end
    end)
    control:Set(options.Items or {}, true)
    return hub:_finishRequiredControl(control)
end

function Section:InfoList(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local row = self:_row(0, "InfoList_" .. (options.Name or "Details"))
    row.AutomaticSize = Enum.AutomaticSize.Y
    local control = self:_control("InfoList", options, row)
    control.Items = {}
    local indexByKey = {}
    local panel = create("Frame", {
        Name = "InfoListPanel", BackgroundColor3 = themeColor(theme, "Section"),
        BackgroundTransparency = .25, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
    }, { corner(8), padding(8, 9, 8, 9), list(Enum.FillDirection.Vertical, 2) })
    if options.Name then
        text({
            Parent = panel, Text = options.Name,
            TextColor3 = themeColor(theme, "SubText"),
            TextSize = 11, FontFace = inter(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20),
        })
    end
    local lines = {}
    local function rebuild()
        -- Stable keyed rows also preserve native touch/hover state on reorder.
        local previous = {}
        for _, line in lines do previous[line.Name] = line end
        local arranged = {}
        for i, item in control.Items do
            local name = "Detail_" .. item.Key
            local line = previous[name]
            previous[name] = nil
            if not line then
                line = create("Frame", { Name = name, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 29), Parent = panel })
                text({ Parent = line, Name = "Key", Text = item.Label,
                    TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
                    Position = UDim2.fromOffset(1, 0), Size = UDim2.new(.49, -3, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd })
                text({ Parent = line, Name = "Value", Text = item.Value,
                    TextColor3 = themeColor(theme, item.Tone),
                    TextXAlignment = Enum.TextXAlignment.Right, TextSize = 12,
                    Position = UDim2.new(.5, 0, 0, 0),
                    Size = UDim2.new(.5, -2, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
                create("Frame", { Name = "Separator",
                    BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -1),
                    Size = UDim2.new(1, 0, 0, 1), Parent = line })
            end
            line.LayoutOrder = i
            local label, value, separator = line:FindFirstChild("Key"), line:FindFirstChild("Value"), line:FindFirstChild("Separator")
            if label and label.Text ~= item.Label then label.Text = item.Label end
            if value then
                if value.Text ~= item.Value then value.Text = item.Value end
                setThemed(value, "TextColor3", themeColor(theme, item.Tone))
            end
            if separator then separator.Visible = i < #control.Items end
            table.insert(arranged, line)
        end
        for _, line in previous do line:Destroy() end
        lines = arranged
    end
    function control:Set(items, silent)
        local nextItems = infoNormalize(items)
        local stable = #nextItems == #self.Items
        if stable then
            for i, item in nextItems do
                if self.Items[i].Key ~= item.Key then stable = false; break end
            end
        end
        self.Items = nextItems
        indexByKey = moduleInfoIndex(nextItems)
        if stable then
            for i, item in nextItems do
                local line = lines[i]
                if line then
                    local label = line:FindFirstChild("Key")
                    local value = line:FindFirstChild("Value")
                    if label and label.Text ~= item.Label then label.Text = item.Label end
                    if value then
                        if value.Text ~= item.Value then value.Text = item.Value end
                        setThemed(value, "TextColor3", themeColor(theme, item.Tone))
                    end
                end
            end
        else
            rebuild()
        end
        if not silent then infoPublish(self, "Set") end
        return true
    end
    function control:Update(key, value, tone, silent)
        local i = indexByKey[tostring(key)]
        local item = i and self.Items[i]
        if not item then return false end
        local nextValue = moduleString(value)
        if item.Value ~= nextValue then
            item.Value = nextValue
            local label = lines[i] and lines[i]:FindFirstChild("Value")
            if label then label.Text = nextValue end
        end
        if tone and item.Tone ~= moduleTone(tone) then
            item.Tone = moduleTone(tone)
            local label = lines[i] and lines[i]:FindFirstChild("Value")
            if label then setThemed(label, "TextColor3", themeColor(theme, item.Tone)) end
        end
        if not silent then infoPublish(self, "Update", tostring(key)) end
        return true
    end
    -- Strict batching validates every key before mutating any row.
    -- Default mode retains the old best-effort count-based contract.
    function control:UpdateMany(values, strict)
        local requireAll = strict == true or (type(strict) == "table" and strict.Strict == true)
        local silent = type(strict) == "table" and strict.Silent == true
        if type(values) ~= "table" then
            if requireAll then return false, "updates must be a table" end
            return 0
        end
        if requireAll then
            for key, update in values do
                if not indexByKey[tostring(key)] then
                    return false, "unknown information key: " .. tostring(key)
                end
                if type(update) == "table" and update.Value == nil then
                    return false, "batch entry requires Value: " .. tostring(key)
                end
            end
        end
        local count = 0
        for key, update in values do
            local ok
            if type(update) == "table" and update.Value ~= nil then
                ok = self:Update(key, update.Value, update.Tone, true)
            else
                ok = self:Update(key, update, nil, true)
            end
            if ok then count += 1 end
        end
        if count > 0 and not silent then infoPublish(self, "Batch") end
        return count
    end
    function control:UpdateManyStrict(values)
        return self:UpdateMany(values, true)
    end
    function control:Upsert(item)
        assert(type(item) == "table" and item.Key ~= nil, "InfoList:Upsert needs a Key")
        local entry = infoNormalize({ item })[1]
        local current = indexByKey[entry.Key]
        local nextItems = moduleInfoSnapshot(self.Items)
        if current then nextItems[current] = entry else table.insert(nextItems, entry) end
        self:Set(nextItems, true)
        infoPublish(self, "Upsert", entry.Key)
        return true
    end
    function control:Remove(key)
        local i = indexByKey[tostring(key)]
        if not i then return false end
        local nextItems = moduleInfoSnapshot(self.Items)
        table.remove(nextItems, i)
        self:Set(nextItems, true)
        infoPublish(self, "Remove", tostring(key))
        return true
    end
    function control:Clear() return self:Set({}) end
    function control:Get() return moduleInfoSnapshot(self.Items) end
    function control:GetItem(key)
        local index = indexByKey[tostring(key)]
        return index and table.clone(self.Items[index]) or nil
    end
    function control:SetOrder(order)
        local arranged, err = infoReorder(self.Items, order)
        if not arranged then return false, err end
        local previous = {}
        for i, item in self.Items do previous[item.Key] = lines[i] end
        self.Items = arranged
        indexByKey = moduleInfoIndex(arranged)
        local reordered = {}
        for i, item in arranged do
            local line = previous[item.Key]
            line.LayoutOrder = i
            reordered[i] = line
            local separator = line:FindFirstChild("Separator")
            if separator then separator.Visible = i < #arranged end
        end
        lines = reordered
        infoPublish(self, "Order")
        return true
    end
    hub:BindToken(panel, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(panel:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
    hub:_connect(row.Destroying, function() hub:_dataDetachControl(control) end)
    control:Set(options.Items or {}, true)
    return hub:_finishRequiredControl(control)
end

end
-- SPDX-License-Identifier: MPL-2.0
-- Owner-scoped explicit data links. No global listeners or hidden polling.
do
    -- Per-hub bounded synchronous cascades avoid cyclic/branching runaway.
    local MAX_CASCADE_HOPS, MAX_CASCADE_DEPTH = 64, 24
    function Hub:LinkData(source, target, options)
        options = type(options) == "table" and options or {}
        assert(type(source) == "table" and type(source.OnDataEvent) == "function",
            "LinkData requires a source control with OnDataEvent")
        assert(type(target) == "table", "LinkData requires a target control")
        assert(source.Section and source.Section.Hub == self
            and target.Section and target.Section.Hub == self,
            "LinkData controls must belong to the same hub")
        assert(not source._disposed and not target._disposed, "cannot link destroyed controls")
        local event = options.Event or "Selection"
        local action = options.Action or "Select"
        local supported = { Select = true, SetQuery = true, SetFilter = true,
            SetExpanded = true, SetLayoutMode = true, Update = true, UpdateMany = true,
            Append = true, Set = true, SetStatus = true, SetSummary = true,
            SetFavorite = true, SetLocked = true, SetOrder = true }
        assert(supported[action] or type(options.Apply) == "function",
            "unsupported data link action")
        assert(type(event) == "string" and event ~= "", "LinkData event must be a string")
        assert(options.Map == nil or type(options.Map) == "function", "Map must be a function")
        assert(options.Filter == nil or type(options.Filter) == "function", "Filter must be a function")
        if not options.Apply then
            assert(type(target[action]) == "function", "target does not support " .. action)
        end
        local links = self._dataLinks
        if not links then links = {}; self._dataLinks = links end
        local link = { Source = source, Target = target, Event = event,
            Action = action, Options = table.clone(options),
            Connected = true, Busy = false, Paused = options.Paused == true,
            Delivered = 0, Skipped = 0, Errors = 0, LastError = nil,
            Cycles = 0, Overflow = 0 }
        local subscription
        local function relay(payload)
            if not link.Connected or self._destroyed or source._disposed or target._disposed then
                return false, "link disconnected"
            end
            if link.Paused or link.Busy then
                link.Skipped += 1
                if link.Busy then link.Cycles += 1 end
                return false, link.Paused and "link paused" or "reentrant event"
            end
            local cascade = self._dataLinkCascade
            local root = cascade == nil
            if root then
                cascade = { Seen = {}, Hops = 0, Depth = 0 }
                self._dataLinkCascade = cascade
            end
            if cascade.Seen[link] then
                link.Skipped += 1
                link.Cycles += 1
                if root then self._dataLinkCascade = nil end
                return false, "cascade already visited link"
            end
            if cascade.Hops >= MAX_CASCADE_HOPS or cascade.Depth >= MAX_CASCADE_DEPTH then
                link.Skipped += 1
                link.Overflow += 1
                if root then self._dataLinkCascade = nil end
                return false, "cascade propagation limit reached"
            end
            cascade.Seen[link] = true
            cascade.Hops += 1
            cascade.Depth += 1
            link.Busy = true
            local applied, skipped = false, false
            local ok, err = xpcall(function()
                if options.Filter and not options.Filter(payload, source, target) then
                    skipped = true
                    return
                end
                local mapped = payload
                if options.Map then mapped = options.Map(payload, source, target) end
                if mapped == nil then skipped = true; return end
                local result, reason
                if options.Apply then
                    result, reason = options.Apply(target, mapped, source)
                elseif action == "Select" then
                    result, reason = target:Select(type(mapped) == "table" and mapped.Id or mapped, true)
                elseif action == "SetExpanded" then
                    assert(type(mapped) == "table" and mapped.Id ~= nil,
                        "SetExpanded link requires { Id, Expanded }")
                    result, reason = target:SetExpanded(mapped.Id, mapped.Expanded)
                elseif action == "Update" then
                    assert(type(mapped) == "table" and (mapped.Id ~= nil or mapped.Key ~= nil),
                        "Update link requires { Id/Key, Value/Changes }")
                    local key = mapped.Id or mapped.Key
                    if target.Type == "InfoGrid" or target.Type == "InfoList" then
                        local value = mapped.Value
                        if value == nil then value = mapped.Changes end
                        result, reason = target:Update(key, value, mapped.Tone, options.Silent == true)
                    else
                        result, reason = target:Update(key, mapped.Changes or mapped, options.Silent == true)
                    end
                elseif action == "UpdateMany" then
                    result, reason = target:UpdateMany(mapped, {
                        Strict = options.Strict == true,
                        Silent = options.Silent == true,
                    })
                elseif action == "SetStatus" then
                    if type(mapped) == "table" then
                        local value = mapped.Status
                        if value == nil then value = mapped.Value end
                        result, reason = target:SetStatus(value, mapped.Tone)
                    else result, reason = target:SetStatus(mapped) end
                elseif action == "SetLocked" then
                    if type(mapped) == "table" then
                        result, reason = target:SetLocked(mapped.Locked == true, mapped.Reason)
                    else result, reason = target:SetLocked(mapped == true) end
                else
                    result, reason = target[action](target, mapped)
                end
                -- Void setters signal successful application through their lack
                -- of an explicit false result; false-returning setters are failures.
                if result == false then error(tostring(reason or "target rejected linked value")) end
                applied = true
            end, debug.traceback)
            link.Busy = false
            cascade.Depth -= 1
            if root then self._dataLinkCascade = nil end
            if not ok then
                link.Errors += 1
                link.LastError = tostring(err)
                warn("[RiftUI] data link: " .. tostring(err))
                return false, link.LastError
            end
            if skipped then
                link.Skipped += 1
                return false, "event filtered"
            end
            if applied then
                link.Delivered += 1
                link.LastError = nil
            end
            return applied
        end
        local getters = {
            Selection = "GetSelection", Value = "Get", Status = "GetStatus",
            Summary = "GetSummary", Favorite = "IsFavorite",
            Expanded = "GetExpandedPreference", Locked = "IsLocked", Data = "Get",
        }
        local function currentPayload()
            local getter = getters[event]
            if not getter or type(source[getter]) ~= "function" then
                return false, "event has no snapshot getter: " .. event
            end
            local ok, payload = pcall(source[getter], source)
            if not ok then return false, tostring(payload) end
            -- Immediate and Refresh Data notifications share the live event schema.
            if event == "Data" then
                payload = { Operation = "Snapshot", Items = payload }
            end
            return true, payload
        end
        function link:Pause()
            if not self.Connected then return false, "link disconnected" end
            self.Paused = true
            self.Options.Paused = true
            return true
        end
        function link:Resume(sync)
            if not self.Connected then return false, "link disconnected" end
            self.Paused = false
            self.Options.Paused = false
            if sync == true then return self:Refresh() end
            return true
        end
        function link:Refresh()
            if not self.Connected then return false, "link disconnected" end
            local ok, payload = currentPayload()
            if not ok then return false, payload end
            -- nil is a valid selection clearing value; other events with nil
            -- payload are intentionally skipped by the mapping contract.
            if payload == nil and event ~= "Selection" then
                return false, "snapshot unavailable"
            end
            return relay(payload)
        end
        function link:GetStats()
            return { Connected = self.Connected, Paused = self.Paused,
                Delivered = self.Delivered, Skipped = self.Skipped,
                Errors = self.Errors, LastError = self.LastError,
                Cycles = self.Cycles, Overflow = self.Overflow,
                Event = self.Event, Action = self.Action }
        end
        subscription = source:OnDataEvent(event, relay)
        function link:Disconnect()
            -- Close over the live subscription, not the caller. An old link
            -- reference forwarded after Reinitialize must still disconnect it.
            if not link.Connected then return end
            link.Connected = false
            if subscription then subscription:Disconnect(); subscription = nil end
            links[link] = nil
        end
        links[link] = true
        if options.Immediate == true and not link.Paused then
            link:Refresh()
        end
        return link
    end

    function Hub:_dataDetachControl(control)
        for link in table.clone(self._dataLinks or {}) do
            if link.Source == control or link.Target == control then link:Disconnect() end
        end
        control._disposed = true
        if control._dataSubscriptions then
            for handle in table.clone(control._dataSubscriptions) do handle:Disconnect() end
            table.clear(control._dataSubscriptions)
        end
        if control._dataObservers then table.clear(control._dataObservers) end
    end

    function Hub:_clearDataLinks()
        for link in table.clone(self._dataLinks or {}) do link:Disconnect() end
        self._dataLinks = nil
        for handle in table.clone(self._directDataSubscriptions or {}) do handle:Disconnect() end
        self._directDataSubscriptions = nil
        self._dataLinkCascade = nil
    end
end

do
-- SPDX-License-Identifier: MPL-2.0
-- ContextMenu: compact contextual actions, anchored to existing OverlayStack popup.
-- Supports right-click, touch long press, nested items and explicit API opens.
do
    local function validateMenu(items, depth)
        assert(type(items) == "table", "ContextMenu.Items must be an array")
        assert(depth <= 4, "ContextMenu nested depth exceeds 4")
        assert(#items <= 100, "ContextMenu supports up to 100 entries per level")
        local copy = {}
        for i, raw in items do
            assert(type(raw) == "table", "ContextMenu entry must be a table")
            local item = table.clone(raw)
            item.Id = tostring(item.Id or item.Key or i)
            item.Text = tostring(item.Text or item.Title or item.Name or item.Id)
            if item.Children ~= nil then item.Children = validateMenu(item.Children, depth + 1) end
            copy[i] = item
        end
        return copy
    end

    function Hub:OpenContextMenu(anchor, items, options)
        if self._destroyed then return nil, "hub destroyed" end
        if not anchor or not anchor:IsDescendantOf(self.Gui) then
            return nil, "ContextMenu anchor must be inside hub GUI"
        end
        options = type(options) == "table" and options or {}
        local entries = validateMenu(items or options.Items or {}, 1)
        local menu = { Closed = false, Items = entries, Anchor = anchor }
        local theme = self.Theme
        local menuWidth = math.clamp(tonumber(options.Width) or 228, 170, 340)
        local lineHeight = 37
        local frame = create("Frame", {
            Name = "ContextMenu", Parent = nil,
            BackgroundColor3 = self:GetToken("Color.PopupSurface"),
            Size = UDim2.fromOffset(menuWidth, 48),
            ZIndex = 41,
        }, { corner(self:GetToken("Components.Popup.Radius")),
            stroke(self:GetToken("Color.PopupBorder"), 1, .30) })
        local scroll = create("ScrollingFrame", {
            Name = "ContextRows", Parent = frame,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Size = UDim2.fromScale(1, 1), ZIndex = 42,
        })
        local page = entries
        local history = {}
        local rows = {}
        local connections = {}
        local function connect(signal, callback)
            local c = signal:Connect(callback)
            table.insert(connections, c)
            return c
        end
        local function clearRows()
            for _, connection in connections do connection:Disconnect() end
            table.clear(connections)
            for _, node in rows do node:Destroy() end
            table.clear(rows)
        end
        local function render()
            if menu.Closed then return end
            clearRows()
            local y = 5
            if #history > 0 then
                local back = create("TextButton", {
                    Name = "Back", Parent = scroll, Text = "‹   返回",
                    BackgroundTransparency = 1, AutoButtonColor = false,
                    TextColor3 = self:GetToken("Color.TextSecondary"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                    Position = UDim2.fromOffset(9, y),
                    Size = UDim2.new(1, -18, 0, 32), ZIndex = 43,
                })
                table.insert(rows, back)
                connect(back.MouseButton1Click, function()
                    page = table.remove(history)
                    render()
                end)
                y += 34
            end
            for index, item in page do
                if item.Separator or item.Divider then
                    local divider = create("Frame", {
                        Name = "Separator", Parent = scroll,
                        BackgroundColor3 = self:GetToken("Color.BorderSubtle"),
                        BackgroundTransparency = .38, BorderSizePixel = 0,
                        Position = UDim2.fromOffset(12, y + 5),
                        Size = UDim2.new(1, -24, 0, 1), ZIndex = 43,
                    })
                    table.insert(rows, divider)
                    y += 12
                else
                    local disabled = item.Disabled == true
                    local hit = create("TextButton", {
                        Name = "Action_" .. item.Id, Parent = scroll,
                        BackgroundColor3 = self:GetToken("Color.PopupItemSelected"),
                        BackgroundTransparency = 1, AutoButtonColor = false,
                        Active = not disabled, Text = "",
                        Position = UDim2.fromOffset(5, y),
                        Size = UDim2.new(1, -10, 0, lineHeight), ZIndex = 43,
                    }, { corner(7) })
                    table.insert(rows, hit)
                    local left = 11
                    if type(item.Icon) == "string" then
                        local icon = iconLabel(item.Icon, 15,
                            self:GetToken("Color.TextSecondary"), {
                            Parent = hit, Position = UDim2.fromOffset(11, 11), ZIndex = 44,
                        })
                        if icon then left = 34 end
                    end
                    text({ Parent = hit, Name = "Label", Text = item.Text,
                        FontFace = inter(Enum.FontWeight.Medium), TextSize = 12,
                        TextColor3 = disabled and self:GetToken("Color.TextMuted")
                            or self:GetToken(item.Danger and "Color.Danger" or "Color.PopupItemText"),
                        Position = UDim2.fromOffset(left, 0),
                        Size = UDim2.new(1, -left - 36, 1, 0),
                        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 44 })
                    text({ Parent = hit, Name = "Shortcut",
                        Text = item.Children and "›" or tostring(item.Shortcut or ""),
                        TextSize = 11, TextColor3 = self:GetToken("Color.TextMuted"),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Position = UDim2.new(1, -48, 0, 0),
                        Size = UDim2.fromOffset(37, lineHeight), ZIndex = 44 })
                    connect(hit.MouseEnter, function()
                        if not disabled then Motion.play(self, "context-hover:" .. tostring(hit),
                            hit, { BackgroundTransparency = .76 }, Motion.Presets.Micro) end
                    end)
                    connect(hit.MouseLeave, function()
                        Motion.play(self, "context-hover:" .. tostring(hit),
                            hit, { BackgroundTransparency = 1 }, Motion.Presets.Micro)
                    end)
                    connect(hit.MouseButton1Click, function()
                        if menu.Closed or disabled or not self._popup
                            or self._popup.Frame ~= frame
                            or not self:_overlayTop()
                            or self:_overlayTop().Owner ~= self._popup.Holder then return end
                        if item.Children then
                            table.insert(history, page)
                            page = item.Children
                            render()
                        else
                            menu:Close()
                            local callback = item.Callback or options.Callback
                            if type(callback) == "function" then
                                local ok, err = pcall(callback, item.Id, item, index)
                                if not ok then warn("[RelaxUI ContextMenu] " .. tostring(err)) end
                            end
                        end
                    end)
                    y += lineHeight + 1
                end
            end
            if #page == 0 then
                local empty = text({ Parent = scroll, Name = "Empty", Text = options.EmptyText or "无可用操作",
                    TextSize = 12, TextColor3 = self:GetToken("Color.TextMuted"),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 36) })
                table.insert(rows, empty)
                y += 36
            end
            frame.Size = UDim2.fromOffset(menuWidth, math.min(y + 6,
                (tonumber(options.MaxHeight) or 296)))
            scroll.CanvasSize = UDim2.fromOffset(0, y + 6)
            scroll.CanvasPosition = Vector2.zero
        end
        function menu:IsOpen() return not self.Closed end
        function menu:SetItems(nextItems)
            if self.Closed then return false end
            self.Items = validateMenu(nextItems, 1)
            page = self.Items
            table.clear(history)
            render()
            return true
        end
        function menu:Close()
            if self.Closed then return end
            self.Closed = true
            if self.Hub._popup and self.Hub._popup.Frame == frame then self.Hub:_closePopup() end
        end
        menu.Hub = self
        self:_openPopup(anchor, frame, function()
            menu.Closed = true
            clearRows()
            for _, c in connections do c:Disconnect() end
            table.clear(connections)
        end, {
            Align = "Left",
            Gap = 3,
            PreferBelow = true,
            MinimumBelowHeight = 80,
        })
        if not self._popup or self._popup.Frame ~= frame then return nil, "popup unavailable" end
        self:BindToken(frame, "BackgroundColor3", "Color.PopupSurface")
        self:BindToken(frame:FindFirstChildOfClass("UIStroke"), "Color", "Color.PopupBorder")
        render()
        return menu
    end

    function Hub:BindContextMenu(anchor, entries, options)
        if not anchor or not anchor:IsDescendantOf(self.Gui) then
            return nil, "invalid context menu target"
        end
        options = type(options) == "table" and options or {}
        local hub = self
        local handle = { Connected = true, Menu = nil, _suppressedTouch = nil }
        local held, serial, origin = nil, 0, nil
        local conns = {}
        local gestureConns = {}
        local function releaseGesture()
            for _, connection in gestureConns do connection:Disconnect() end
            table.clear(gestureConns)
            held, origin = nil, nil
        end
        local function cancelGesture()
            serial += 1
            releaseGesture()
        end
        local function connect(signal, callback)
            table.insert(conns, signal:Connect(callback))
        end
        function handle:Open()
            -- All entry paths (click, right mouse, touch long press and API)
            -- must obey the same optional availability gate.
            if not self.Connected or hub._destroyed then return nil end
            if type(options.CanOpen) == "function" and not options.CanOpen() then
                return nil
            end
            local menu = hub:OpenContextMenu(anchor, entries, options)
            self.Menu = menu
            return menu
        end
        function handle:ConsumeTap()
            local suppressed = self._suppressedTouch
            self._suppressedTouch = nil
            -- Only consume the click emitted by the same touch release.
            -- Stale suppression may not swallow a later independent tap.
            return suppressed ~= nil and os.clock() - suppressed < .3
        end
        function handle:SetItems(items)
            entries = validateMenu(items, 1)
            if self.Menu and self.Menu:IsOpen() then self.Menu:SetItems(entries) end
        end
        function handle:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            cancelGesture()
            self._suppressedTouch = nil
            if self.Menu and self.Menu:IsOpen() then self.Menu:Close() end
            for _, conn in conns do conn:Disconnect() end
            table.clear(conns)
        end
        connect(anchor.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                handle:Open()
                return
            end
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            -- Global listeners are active only during the held gesture.
            -- The original anchor stops receiving events when the finger
            -- leaves it, so off-anchor releases must be handled centrally.
            if held then cancelGesture(); return end
            held, origin = input, input.Position
            self._suppressedTouch = nil
            serial += 1
            local ticket = serial
            table.insert(gestureConns, UserInputService.InputChanged:Connect(function(changed)
                if changed ~= input or not held then return end
                if changed.UserInputState == Enum.UserInputState.Cancel
                    or changed.UserInputState == Enum.UserInputState.End
                    or (changed.Position - origin).Magnitude > 12 then
                    cancelGesture()
                end
            end))
            table.insert(gestureConns, UserInputService.InputEnded:Connect(function(ended)
                if ended == input then cancelGesture() end
            end))
            table.insert(gestureConns, UserInputService.InputBegan:Connect(function(other)
                if held and other ~= input and other.UserInputType == Enum.UserInputType.Touch then
                    cancelGesture()
                end
            end))
            task.delay(math.clamp(tonumber(options.LongPressTime) or .55, .45, .65), function()
                if handle.Connected and serial == ticket and held == input then
                    releaseGesture()
                    handle._suppressedTouch = os.clock()
                    handle:Open()
                end
            end)
        end)
        connect(anchor.Destroying, function() handle:Disconnect() end)
        return handle
    end

    function Section:ContextMenu(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(44, "ContextMenu_" .. (options.Name or "Actions"))
        local c = self:_control("ContextMenu", options, row)
        local trigger = create("TextButton", {
            Name = "ContextTrigger", Parent = row,
            Text = tostring(options.Name or "更多操作"),
            FontFace = inter(Enum.FontWeight.Medium),
            TextSize = hub:GetToken("Typography.ControlLabel.Size"),
            TextColor3 = hub:GetToken("Color.TextPrimary"),
            BackgroundColor3 = hub:GetToken("Color.Surface2"),
            Size = UDim2.new(1, 0, 0, 40),
            AutoButtonColor = false,
        }, { corner(hub:GetToken("Radius.S")),
            stroke(hub:GetToken("Color.BorderSubtle"), 1, .4) })
        hub:BindToken(trigger, "BackgroundColor3", "Color.Surface2")
        hub:BindToken(trigger, "TextColor3", "Color.TextPrimary")
        local binding = hub:BindContextMenu(trigger, options.Items or {}, {
            Callback = function(id, item)
                -- Availability can change after the popup has opened.
                if not c:IsAvailable() then return end
                c.Value = id
                c:_emit(id, item)
            end,
            LongPressTime = options.LongPressTime,
            Width = options.Width,
            CanOpen = function() return c:IsAvailable() end,
        })
        c.Trigger = trigger
        function c:Get() return self.Value end
        function c:SetItems(items) binding:SetItems(items) end
        function c:Open()
            if not c:IsAvailable() then return nil end
            return binding:Open()
        end
        function c:Close()
            if binding.Menu and binding.Menu:IsOpen() then binding.Menu:Close() end
        end
        hub:_connect(trigger.MouseButton1Click, function()
            if c:IsAvailable() and not binding:ConsumeTap()
                and not hub._popupJustClosed then c:Open() end
        end)
        hub:_connect(row.Destroying, function() binding:Disconnect(); c._disposed = true end)
        return hub:_finishRequiredControl(c)
    end
end

end
do
-- SPDX-License-Identifier: MPL-2.0
-- SearchSelect: searchable single/multiple selection with bounded recycled rows.
do
    local function normalizeChoices(source)
        assert(type(source) == "table", "SearchSelect.Options must be an array")
        local result, ids = {}, {}
        for i, value in source do
            local item = type(value) == "table" and table.clone(value)
                or { Value = value, Label = tostring(value) }
            item.Value = item.Value ~= nil and item.Value or item.Id or item.Label or item.Name or tostring(i)
            item.Label = tostring(item.Label or item.Name or item.Value)
            assert(not ids[item.Value], "SearchSelect requires unique option values")
            ids[item.Value] = true
            result[#result + 1] = item
        end
        return result
    end
    local function copySelection(value)
        if type(value) ~= "table" then return value end
        return table.clone(value)
    end
    function Section:SearchSelect(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local multi = options.Multi == true
        local row = self:_row(43, "SearchSelect_" .. (options.Name or ""))
        local c = self:_control("SearchSelect", options, row)
        c.Options = normalizeChoices(options.Options or options.Values or {})
        c.Multi = multi
        c.Value = multi and {} or nil
        local label = self:_labels(row, c.Name, options.Description, 150)
        local chip = create("TextButton", {
            Name = "SearchSelectChip", Parent = row,
            Text = "", AutoButtonColor = false,
            BackgroundColor3 = hub:GetToken("Color.InputSurface"),
            AnchorPoint = Vector2.new(1, .5), Position = UDim2.fromScale(1, .5),
            Size = UDim2.fromOffset(150, 32),
        }, { corner(hub:GetToken("Components.Input.Radius")),
            stroke(hub:GetToken("Color.InputBorder"), 1, .35) })
        local shown = text({ Name = "Value", Parent = chip, Text = options.Placeholder or "请选择",
            TextSize = hub:GetToken("Typography.ControlLabel.Size"),
            TextColor3 = hub:GetToken("Color.TextSecondary"),
            Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -32, 1, 0),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local arrow = iconLabel("chevron-down", 14, hub:GetToken("Color.TextSecondary"), {
            Parent = chip, AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.new(1, -15, .5, 0),
        })
        local popup, popupConns, optionsViewport, queryBox, emptyLabel
        local filtered, nodes = {}, {}
        local rowHeight = 34
        local maxVisible = math.clamp(tonumber(options.MaxVisible) or 6, 3, 10)
        local recent = {}
        local function selected(item)
            if multi then return c.Value[item.Value] == true end
            return c.Value == item.Value
        end
        local function getValue()
            return copySelection(c.Value)
        end
        local function refreshLabel()
            if multi then
                local count = 0
                local names = {}
                for _, item in c.Options do
                    if selected(item) then
                        count += 1
                        if #names < 2 then table.insert(names, item.Label) end
                    end
                end
                shown.Text = count == 0 and (options.Placeholder or "请选择")
                    or count > 2 and (tostring(count) .. " 已选择")
                    or table.concat(names, ", ")
            else
                shown.Text = options.Placeholder or "请选择"
                for _, item in c.Options do
                    if selected(item) then shown.Text = item.Label; break end
                end
            end
        end
        function c:Get() return getValue() end
        function c:Set(value, silent)
            if multi then
                local picked = {}
                if type(value) == "table" then
                    for k, v in value do
                        if type(k) == "number" then picked[v] = true
                        elseif v then picked[k] = true end
                    end
                end
                self.Value = picked
            else
                self.Value = value
            end
            refreshLabel()
            if not silent then self:_emit(getValue()) end
            -- Updating checkmarks must not reset the scrolling list to its
            -- first row. Query / option changes are the only reset points.
            if popup and optionsViewport then c:_render() end
            return true
        end
        function c:SetOptions(source, silent)
            local replacement = normalizeChoices(source)
            local known = {}
            for _, item in replacement do known[item.Value] = true end
            -- Replacing a data source must not retain a selection that the
            -- user can no longer find or clear from the visible options.
            local changed = false
            if multi then
                local kept = {}
                for value, enabled in self.Value do
                    if enabled and known[value] then kept[value] = true
                    elseif enabled then changed = true end
                end
                self.Value = kept
            elseif self.Value ~= nil and not known[self.Value] then
                self.Value = nil
                changed = true
            end
            self.Options = replacement
            for i = #recent, 1, -1 do
                if not known[recent[i]] then table.remove(recent, i) end
            end
            refreshLabel()
            if popup then c:_filter(queryBox and queryBox.Text or "") end
            if changed and not silent then self:_emit(getValue()) end
            return true
        end
        local function disconnectPopup()
            popup = nil
            for _, connection in popupConns or {} do connection:Disconnect() end
            popupConns = nil
            for _, node in nodes do node:Destroy() end
            table.clear(nodes)
            queryBox, optionsViewport, emptyLabel = nil, nil, nil
        end
        function c:_filter(query)
            if not optionsViewport then return end
            local needle = string.lower(tostring(query or ""))
            table.clear(filtered)
            local seen = {}
            if needle == "" then
                for _, value in recent do
                    for _, item in self.Options do
                        if item.Value == value and not seen[item.Value] then
                            seen[item.Value] = true
                            table.insert(filtered, item)
                            break
                        end
                    end
                end
            end
            for _, item in self.Options do
                if not seen[item.Value] and (string.find(string.lower(item.Label), needle, 1, true)
                    or string.find(string.lower(tostring(item.Value)), needle, 1, true)) then
                    table.insert(filtered, item)
                end
            end
            optionsViewport.CanvasPosition = Vector2.zero
            self:_render()
        end
        function c:_render()
            if not optionsViewport then return end
            local scale = math.max(hub._scale or 1, .01)
            local start = math.floor(optionsViewport.CanvasPosition.Y /
                math.max(rowHeight * scale, 1)) + 1
            -- The shared popup may shrink to fit a short landscape viewport:
            -- never clamp scrolling based on the configured MaxVisible count.
            local viewportHeight = optionsViewport.AbsoluteSize.Y
            local visibleRows = viewportHeight > 0
                and math.max(1, math.floor(viewportHeight / (rowHeight * scale)))
                or maxVisible
            visibleRows = math.min(maxVisible, visibleRows)
            start = math.clamp(start, 1, math.max(1, #filtered - visibleRows + 1))
            local capacity = math.min(maxVisible + 2, #filtered)
            for i = 1, math.max(capacity, #nodes) do
                local item = filtered[start + i - 1]
                local hit = nodes[i]
                if item then
                    if not hit then
                        hit = create("TextButton", {
                            Name = "SearchRow", Parent = optionsViewport,
                            AutoButtonColor = false, Text = "",
                            BackgroundColor3 = hub:GetToken("Color.PopupItemSelected"),
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -8, 0, rowHeight - 1),
                            ZIndex = 45,
                        }, { corner(6) })
                        local valueText = text({ Name = "Label", Parent = hit,
                            Text = "", TextSize = hub:GetToken("Typography.PopupItem.Size"),
                            TextColor3 = hub:GetToken("Color.PopupItemText"),
                            Position = UDim2.fromOffset(10, 0),
                            Size = UDim2.new(1, -45, 1, 0), ZIndex = 46,
                            TextTruncate = Enum.TextTruncate.AtEnd })
                        text({ Name = "Check", Parent = hit, Text = "✓",
                            TextSize = 13, TextColor3 = hub:GetToken("Color.Accent"),
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Position = UDim2.new(1, -30, 0, 0),
                            Size = UDim2.fromOffset(20, rowHeight), ZIndex = 46 })
                        hub:BindToken(valueText, "TextColor3", "Color.PopupItemText")
                        local connection = hit.MouseButton1Click:Connect(function()
                            local chosen = hit:GetAttribute("OptionIndex")
                            local selectedItem = chosen and filtered[chosen]
                            if not selectedItem or selectedItem.Disabled == true
                                or not c:IsAvailable() then return end
                            if multi then
                                local nextValue = table.clone(c.Value)
                                nextValue[selectedItem.Value] = not nextValue[selectedItem.Value] or nil
                                c:Set(nextValue)
                            else
                                c:Set(selectedItem.Value)
                                hub:_closePopup()
                            end
                            table.insert(recent, 1, selectedItem.Value)
                            if #recent > 8 then table.remove(recent) end
                        end)
                        table.insert(popupConns, connection)
                        nodes[i] = hit
                    end
                    hit.Visible = true
                    hit.Position = UDim2.fromOffset(4, (start + i - 2) * rowHeight + 2)
                    hit:SetAttribute("OptionIndex", start + i - 1)
                    local chosen = selected(item)
                    hit.BackgroundTransparency = chosen and .78 or 1
                    hit:FindFirstChild("Label").Text = item.Label
                    hit:FindFirstChild("Check").Visible = chosen
                    hit.Active = item.Disabled ~= true
                elseif hit then
                    hit.Visible = false
                    hit:SetAttribute("OptionIndex", nil)
                end
            end
            optionsViewport.CanvasSize = UDim2.fromOffset(0, #filtered * rowHeight + 8)
            if emptyLabel then emptyLabel.Visible = #filtered == 0 end
            -- Do not leave four empty option rows when a short list or a
            -- filtered query has only one or two results.
            local visibleCount = math.max(1, math.min(maxVisible, #filtered))
            local nextHeight = 44 + visibleCount * rowHeight + 10
            if popup and popup.Size.Y.Offset ~= nextHeight then
                popup.Size = UDim2.fromOffset(popup.Size.X.Offset, nextHeight)
                -- A changing search result height may change popup direction.
                -- Reposition now, without waiting for an AbsoluteSize event.
                if hub._popup and hub._popup.Frame == popup then
                    hub:_placePopup(hub._popup, false)
                end
            end
        end
        function c:Open()
            if not self:IsAvailable() or hub._destroyed then return nil end
            if popup then return popup end
            -- Match initial menu geometry to the actual option count before
            -- registering the popup; avoid an opening height/flip jump.
            local initialVisible = math.max(1, math.min(maxVisible, #self.Options))
            local pane = create("Frame", {
                Name = "SearchSelectPopup", BackgroundColor3 = hub:GetToken("Color.PopupSurface"),
                -- Keep the popup visually attached to the 150px field. A
                -- wider menu remains available explicitly via options.Width.
                Size = UDim2.fromOffset(math.clamp(tonumber(options.Width) or 176,
                    150, 340), 44 + initialVisible * rowHeight + 10), ZIndex = 42,
            }, { corner(hub:GetToken("Components.Popup.Radius")),
                stroke(hub:GetToken("Color.PopupBorder"), 1, .3) })
            queryBox = create("TextBox", {
                Name = "SearchQuery", Parent = pane,
                BackgroundColor3 = hub:GetToken("Color.InputSurface"),
                TextColor3 = hub:GetToken("Color.InputText"),
                PlaceholderText = options.SearchPlaceholder or "搜索选项…",
                PlaceholderColor3 = hub:GetToken("Color.TextMuted"),
                Text = "", ClearTextOnFocus = false,
                TextSize = 13, FontFace = inter(),
                Position = UDim2.fromOffset(7, 7),
                Size = UDim2.new(1, -14, 0, 30), ZIndex = 44,
            }, { corner(7), padding(0, 9) })
            optionsViewport = create("ScrollingFrame", {
                Name = "SearchResults", Parent = pane,
                BackgroundTransparency = 1, BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Position = UDim2.fromOffset(4, 44),
                Size = UDim2.new(1, -8, 1, -48),
                CanvasSize = UDim2.new(), ZIndex = 43,
            })
            emptyLabel = text({ Name = "EmptyResults", Parent = pane,
                Text = options.EmptyText or "没有匹配的选项",
                TextSize = 12, TextColor3 = hub:GetToken("Color.TextMuted"),
                TextXAlignment = Enum.TextXAlignment.Center,
                Position = UDim2.fromOffset(5, 48),
                Size = UDim2.new(1, -10, 0, 40), Visible = false, ZIndex = 46 })
            popupConns = {}
            popup = pane
            table.insert(popupConns, queryBox:GetPropertyChangedSignal("Text"):Connect(function()
                c:_filter(queryBox.Text)
            end))
            table.insert(popupConns, optionsViewport:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                c:_render()
            end))
            table.insert(popupConns, optionsViewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                c:_render()
            end))
            table.insert(popupConns, hub.UIScale:GetPropertyChangedSignal("Scale"):Connect(function()
                c:_render()
            end))
            hub:_openPopup(chip, pane, disconnectPopup, {
                Align = "Center",
                Gap = 3,
                PreferBelow = true,
                MinimumBelowHeight = 96,
            })
            if not hub._popup or hub._popup.Frame ~= pane then
                disconnectPopup()
                return nil
            end
            hub:BindToken(pane, "BackgroundColor3", "Color.PopupSurface")
            hub:BindToken(queryBox, "BackgroundColor3", "Color.InputSurface")
            hub:BindToken(queryBox, "TextColor3", "Color.InputText")
            c:_filter("")
            return pane
        end
        function c:Close()
            if popup and hub._popup and hub._popup.Frame == popup then hub:_closePopup() end
        end
        function c:GetRecent() return table.clone(recent) end
        refreshLabel()
        c:Set(options.Default ~= nil and options.Default or (multi and {} or nil), true)
        hub:BindToken(chip, "BackgroundColor3", "Color.InputSurface")
        hub:BindToken(chip:FindFirstChildOfClass("UIStroke"), "Color", "Color.InputBorder")
        hub:BindToken(shown, "TextColor3", "Color.TextSecondary")
        hub:_connect(chip.MouseButton1Click, function()
            if popup then c:Close() else c:Open() end
        end)
        hub:_connect(row.Destroying, function()
            c:Close()
            c._disposed = true
            if popup then disconnectPopup() end
        end)
        return hub:_finishRequiredControl(c)
    end
end

end
do
-- SPDX-License-Identifier: MPL-2.0
-- Accordion: lightweight content-only disclosure; no module toggle or favorite.
do
    local function accordionItems(items)
        assert(type(items) == "table", "Accordion.Items must be an array")
        local out, seen = {}, {}
        for i, source in items do
            assert(type(source) == "table", "Accordion item must be a table")
            local item = table.clone(source)
            item.Id = tostring(item.Id or item.Key or i)
            assert(not seen[item.Id], "Accordion IDs must be unique")
            seen[item.Id] = true
            item.Title = tostring(item.Title or item.Name or item.Id)
            item.Content = tostring(item.Content or item.Description or "")
            out[#out + 1] = item
        end
        return out
    end
    function Section:Accordion(options)
        options = type(options) == "table" and options or {}
        local hub = self.Hub
        local row = self:_row(0, "Accordion_" .. (options.Name or ""))
        row.AutomaticSize = Enum.AutomaticSize.Y
        local c = self:_control("Accordion", options, row)
        local single = options.Single ~= false
        local items = accordionItems(options.Items or {})
        local expanded = {}
        local searchPeek = false
        local searchMatches = nil
        local slots = {}
        local connections = {}
        local shell = create("Frame", {
            Name = "AccordionShell", Parent = row,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = hub:GetToken("Color.Surface1"),
            BackgroundTransparency = .36,
        }, { corner(hub:GetToken("Radius.S")),
            stroke(hub:GetToken("Color.BorderSubtle"), 1, .55),
            padding(5, 7), list(Enum.FillDirection.Vertical, 3) })
        local function bind(signal, fn)
            local conn = signal:Connect(fn)
            table.insert(connections, conn)
        end
        local function effective(id)
            if searchPeek then
                -- Filtered search is a temporary view, never a mutation of
                -- stored expanded state. Hide unrelated open items while
                -- matching this query; restore them when search clears.
                return searchMatches == nil or searchMatches[id] == true
            end
            return expanded[id] == true
        end
        local function contentHeight(slot)
            return math.max(28, math.ceil(slot.Label.TextBounds.Y /
                math.max(hub._scale or 1, .01)) + 20)
        end
        local function refresh(slot, animate)
            local opened = effective(slot.Id)
            local target = opened and contentHeight(slot) or 0
            if opened then slot.Clip.Visible = true end
            local id = "accordion:" .. tostring(slot.Clip)
            local key = id .. ":arrow"
            if animate then
                Motion.play(hub, id, slot.Clip, {
                    Size = UDim2.new(1, 0, 0, target),
                }, Motion.Presets.Control, function()
                    if not slot.Clip.Parent then return end
                    slot.Clip.Visible = effective(slot.Id)
                    slot.Clip.Size = UDim2.new(1, 0, 0,
                        effective(slot.Id) and contentHeight(slot) or 0)
                end)
                if slot.Arrow then Motion.play(hub, key, slot.Arrow,
                    { Rotation = opened and 90 or 0 }, Motion.Presets.Micro) end
            else
                Motion.cancel(hub, id)
                Motion.cancel(hub, key)
                slot.Clip.Size = UDim2.new(1, 0, 0, target)
                slot.Clip.Visible = opened
                if slot.Arrow then slot.Arrow.Rotation = opened and 90 or 0 end
            end
        end
        local function revealExpanded(slot)
            if hub._destroyed or not row.Parent or not slot.Holder.Parent then return end
            local node = slot.Holder.Parent
            while node do
                if node:IsA("ScrollingFrame") and node.ScrollingDirection ~= Enum.ScrollingDirection.X then
                    local viewTop = node.AbsolutePosition.Y + 8
                    local viewBottom = node.AbsolutePosition.Y + node.AbsoluteSize.Y - 8
                    local itemTop = slot.Holder.AbsolutePosition.Y
                    local itemBottom = itemTop + slot.Holder.AbsoluteSize.Y
                    local delta = 0
                    if itemTop < viewTop then
                        delta = itemTop - viewTop
                    elseif itemBottom > viewBottom then
                        -- When an expanded answer exceeds the viewport, reveal
                        -- its heading first rather than scrolling past it.
                        if itemBottom - itemTop > viewBottom - viewTop then
                            delta = itemTop - viewTop
                        else
                            delta = itemBottom - viewBottom
                        end
                    end
                    if delta ~= 0 then
                        node.CanvasPosition = Vector2.new(node.CanvasPosition.X,
                            math.max(0, node.CanvasPosition.Y + delta))
                    end
                    break
                end
                node = node.Parent
            end
        end
        local revealSerial = 0
        local function repaint(animate)
            for _, slot in slots do refresh(slot, animate) end
        end
        local function emit()
            c.Value = table.clone(expanded)
            c:_emit(c:GetExpanded())
        end
        function c:GetExpanded() return table.clone(expanded) end
        function c:Get() return self:GetExpanded() end
        function c:IsExpanded(id) return expanded[tostring(id)] == true end
        function c:SetExpanded(id, enabled, silent)
            id = tostring(id)
            local found = false
            for _, item in items do
                if item.Id == id then found = true; break end
            end
            if not found then return false, "unknown accordion item" end
            enabled = enabled == true
            if enabled and single then table.clear(expanded) end
            expanded[id] = enabled or nil
            repaint(true)
            if enabled and not silent and not searchPeek then
                -- Let the 200ms size transition finish before revealing.
                -- A later interaction supersedes this queued adjustment.
                revealSerial += 1
                local ticket = revealSerial
                local target
                for _, slot in slots do
                    if slot.Id == id then target = slot; break end
                end
                task.delay(.24, function()
                    if ticket == revealSerial and target and row.Parent
                        and effective(id) then
                        task.defer(function()
                            if ticket == revealSerial then revealExpanded(target) end
                        end)
                    end
                end)
            else
                revealSerial += 1
            end
            if not silent then emit() end
            return true
        end
        function c:Expand(id, silent) return self:SetExpanded(id, true, silent) end
        function c:Collapse(id, silent) return self:SetExpanded(id, false, silent) end
        function c:Toggle(id, silent)
            return self:SetExpanded(id, not self:IsExpanded(id), silent)
        end
        function c:Set(values, silent)
            if type(values) ~= "table" then return false, "expected table" end
            local known = {}
            for _, item in items do known[item.Id] = true end
            local nextExpanded = {}
            for key, value in values do
                local id = type(key) == "number" and tostring(value) or tostring(key)
                if (type(key) == "number" or value == true) and known[id] then
                    nextExpanded[id] = true
                    if single then break end
                end
            end
            expanded = nextExpanded
            repaint(false)
            if not silent then emit() end
            return true
        end
        function c:MatchesSearch(query)
            query = string.lower(tostring(query or ""))
            if query == "" then return true end
            if string.find(string.lower(self.Name), query, 1, true) then return true end
            for _, item in items do
                if string.find(string.lower(item.Title), query, 1, true)
                    or string.find(string.lower(item.Content), query, 1, true) then
                    return true
                end
            end
            return false
        end
        function c:_setSearchPeek(on, query)
            searchPeek = on == true
            searchMatches = nil
            if searchPeek and type(query) == "string" and query ~= "" then
                local lowered = string.lower(query)
                local all = string.find(string.lower(self.Name), lowered, 1, true) ~= nil
                if not all then
                    searchMatches = {}
                    for _, item in items do
                        if string.find(string.lower(item.Title), lowered, 1, true)
                            or string.find(string.lower(item.Content), lowered, 1, true) then
                            searchMatches[item.Id] = true
                        end
                    end
                end
            end
            repaint(false)
        end
        function c:SetItems(nextItems)
            local newItems = accordionItems(nextItems)
            local available = {}
            for _, item in newItems do available[item.Id] = true end
            for id in expanded do if not available[id] then expanded[id] = nil end end
            items = newItems
            self.Value = table.clone(expanded)
            self:Render()
            return true
        end
        function c:Render()
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            for _, slot in slots do
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip))
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip) .. ":arrow")
                slot.Holder:Destroy()
            end
            table.clear(slots)
            for i, item in items do
                local holder = create("Frame", {
                    Name = "Item_" .. item.Id, Parent = shell,
                    LayoutOrder = i, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, { list(Enum.FillDirection.Vertical, 0) })
                local head = create("TextButton", {
                    Name = "AccordionHeader", Parent = holder,
                    BackgroundColor3 = hub:GetToken("Color.Surface2"),
                    BackgroundTransparency = .7,
                    Text = "", AutoButtonColor = false,
                    Size = UDim2.new(1, 0, 0, 42),
                }, { corner(6) })
                local arrow = iconLabel("chevron-right", 15,
                    hub:GetToken("Color.TextSecondary"), {
                    Parent = head, AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.new(0, 18, .5, 0),
                })
                local heading = text({
                    Name = "Title", Parent = head,
                    Text = item.Title, TextSize = hub:GetToken("Typography.ControlLabel.Size"),
                    FontFace = inter(Enum.FontWeight.Medium),
                    TextColor3 = hub:GetToken("Color.TextPrimary"),
                    Position = UDim2.fromOffset(38, 0),
                    Size = UDim2.new(1, -48, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                })
                local clip = create("Frame", {
                    Name = "AccordionClip", Parent = holder,
                    BackgroundTransparency = 1, ClipsDescendants = true,
                    Visible = false, Size = UDim2.new(1, 0, 0, 0),
                })
                local content = create("Frame", {
                    Name = "AccordionContent", Parent = clip,
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, { padding(10, 12) })
                local body = text({
                    Name = "Content", Parent = content, Text = item.Content,
                    TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
                    TextSize = hub:GetToken("Typography.ControlDescription.Size"),
                    TextColor3 = hub:GetToken("Color.TextSecondary"),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                })
                local slot = { Id = item.Id, Holder = holder, Clip = clip,
                    Arrow = arrow, Label = body }
                slots[i] = slot
                hub:BindToken(heading, "TextColor3", "Color.TextPrimary")
                hub:BindToken(body, "TextColor3", "Color.TextSecondary")
                bind(body:GetPropertyChangedSignal("TextBounds"), function()
                    if effective(slot.Id) then refresh(slot, false) end
                end)
                bind(head.MouseButton1Click, function()
                    if c:IsAvailable() then c:Toggle(slot.Id) end
                end)
                refresh(slot, false)
            end
        end
        function c:Destroy()
            if self._disposed then return end
            self._disposed = true
            revealSerial += 1
            if self.Flag and RiftUI.Flags[self.Flag] == self then
                RiftUI.Flags[self.Flag] = nil
            end
            local index = table.find(self.Section.Controls, self)
            if index then table.remove(self.Section.Controls, index) end
            local moduleParent = self._moduleCard
            if moduleParent and moduleParent._moduleControls then
                local nested = table.find(moduleParent._moduleControls, self)
                if nested then table.remove(moduleParent._moduleControls, nested) end
            end
            for i = #(hub._recipe or {}), 1, -1 do
                if hub._recipe[i].Result == self then table.remove(hub._recipe, i) end
            end
            for subscription in self._dataSubscriptions or {} do
                subscription:Disconnect()
            end
            for _, conn in connections do conn:Disconnect() end
            for _, slot in slots do
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip))
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip) .. ":arrow")
            end
            row:Destroy()
        end
        c:Render()
        local defaults = type(options.Default) == "table" and options.Default or {}
        if #defaults == 0 and options.DefaultExpanded then
            for _, item in items do if item.Expanded then defaults[item.Id] = true end end
        end
        c:Set(defaults, true)
        hub:_connect(row.Destroying, function()
            for _, conn in connections do conn:Disconnect() end
            for _, slot in slots do
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip))
                Motion.cancel(hub, "accordion:" .. tostring(slot.Clip) .. ":arrow")
            end
        end)
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        hub:BindToken(shell:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
        return hub:_finishRequiredControl(c)
    end
end

end
-- SPDX-License-Identifier: MPL-2.0
-- Ordered, flag-persistable priority control. No extra global input listeners.
local function complexCloneList(items)
    local out = {}
    for i, item in items do out[i] = type(item) == "table" and table.clone(item) or item end
    return out
end

local function complexString(value)
    return value == nil and "" or tostring(value)
end

local function complexObserve(control, fn)
    return control:OnChanged(fn)
end

-- An explicit Destroy must also unregister the control from all registries.
-- Leaving a detached Frame in Section.Controls breaks search and Reinitialize.
local function complexForgetControl(control)
    local section = control.Section
    if not section then return end
    section.Hub:_dataDetachControl(control)
    if control.Type == "TreeView" and section.Hub._treeControls then
        local index = table.find(section.Hub._treeControls, control)
        if index then table.remove(section.Hub._treeControls, index) end
    end
    local index = table.find(section.Controls, control)
    if index then table.remove(section.Controls, index) end
    local moduleCard = control._moduleCard
    if moduleCard and moduleCard._moduleControls then
        local inside = table.find(moduleCard._moduleControls, control)
        if inside then table.remove(moduleCard._moduleControls, inside) end
    end
    if control.Flag and RiftUI.Flags[control.Flag] == control then
        RiftUI.Flags[control.Flag] = nil
    end
    local recipe = section.Hub._recipe
    if recipe then
        for i = #recipe, 1, -1 do
            if recipe[i].Result == control then table.remove(recipe, i) end
        end
    end
end

function Section:OrderList(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 6), 2, 14)
    -- 42px cells + 2px gap provide larger mobile touch targets.
    local rowStep = 44
    local height = 34 + maxVisible * rowStep
    local row = self:_row(height + 6, "OrderList_" .. (options.Name or "Priority"))
    local c = self:_control("OrderList", options, row)
    local title = text({
        Name = "Title", Parent = row, Text = c.Name,
        TextSize = 13, FontFace = inter(Enum.FontWeight.SemiBold),
        Size = UDim2.new(1, -58, 0, 21), TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local count = text({
        Name = "Count", Parent = row, Text = "",
        TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.new(1, -58, 0, 0), Size = UDim2.fromOffset(58, 20),
    })
    local listBox = create("Frame", {
        Name = "PriorityBox", BackgroundColor3 = themeColor(theme, "Field"),
        BackgroundTransparency = .16,
        Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true, Parent = row,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke"), 1, .34) })
    hub:BindToken(listBox, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(listBox:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
    local scroll = create("ScrollingFrame", {
        Name = "Items", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.new(), Parent = listBox,
    }, { padding(3, 6), list(Enum.FillDirection.Vertical, 2) })
    local empty = text({
        Name = "Empty", Parent = listBox, Text = options.EmptyText or "Nothing to order",
        TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
    })

    local items, byId, nodes = {}, {}, {}
    local order = {}
    local live = true
    local function teardownNodes()
        for _, node in nodes do
            for _, conn in node.Connections do conn:Disconnect() end
            if node.Drag then node.Drag:Disconnect() end
            node.Frame:Destroy()
        end
        table.clear(nodes)
    end
    local function normalize(source)
        assert(type(source) == "table", "OrderList.Items must be an array")
        local out, index = {}, {}
        for i, value in source do
            local item
            if type(value) == "string" then
                item = { Id = value, Label = value, Disabled = false }
            else
                assert(type(value) == "table", "OrderList item must be string or table")
                item = { Id = value.Id or value.Key or tostring(i),
                    Label = complexString(value.Label or value.Name or value.Id or i),
                    Description = complexString(value.Description), Disabled = value.Disabled == true }
            end
            assert(type(item.Id) == "string" and item.Id ~= "" and not index[item.Id], "OrderList requires unique non-empty Id")
            index[item.Id] = item
            table.insert(out, item)
        end
        return out, index
    end
    local function same(a, b)
        if #a ~= #b then return false end
        for i, id in a do if b[i] ~= id then return false end end
        return true
    end
    local function currentOrder()
        return table.clone(order)
    end
    local function layout()
        if not live or hub._destroyed then return end
        local visible = math.max(1, math.min(maxVisible, #order))
        listBox.Size = UDim2.new(1, 0, 0, visible * rowStep + 6)
        row.Size = UDim2.new(1, 0, 0, 26 + visible * rowStep + 10)
        scroll.CanvasSize = UDim2.fromOffset(0, #order * rowStep + 12)
        count.Text = tostring(#order)
        empty.Visible = #order == 0
        for position, id in order do
            local node = nodes[id]
            if node then
                node.Frame.LayoutOrder = position
                node.Pos.Text = string.format("%02d", position)
                node.Up.Visible = not byId[id].Disabled
                node.Down.Visible = not byId[id].Disabled
                local prior, nextId = order[position - 1], order[position + 1]
                node.Up.Active = prior ~= nil and not byId[prior].Disabled
                node.Down.Active = nextId ~= nil and not byId[nextId].Disabled
                node.Up.TextTransparency = node.Up.Active and 0 or .7
                node.Down.TextTransparency = node.Down.Active and 0 or .7
            end
        end
    end
    local function setOrder(nextOrder, silent, strict)
        if type(nextOrder) ~= "table" then return false, "expected array of IDs" end
        local seen, desired = {}, {}
        for _, id in nextOrder do
            if type(id) ~= "string" or seen[id] or not byId[id] then
                if strict then return false, "unknown or duplicate item ID" end
            else
                seen[id] = true
                table.insert(desired, id)
            end
        end
        for _, id in order do
            if not seen[id] and byId[id] then
                seen[id] = true
                table.insert(desired, id)
            end
        end
        -- Locked rows never move: they remain in their original indices even
        -- when a caller supplies a full order with those IDs misplaced.
        local fixed, editable = {}, {}
        for index, id in order do
            if byId[id] and byId[id].Disabled then fixed[index] = id end
        end
        for _, id in desired do
            if not byId[id].Disabled then table.insert(editable, id) end
        end
        local final, nextEditable = {}, 1
        for position = 1, #order do
            final[position] = fixed[position] or editable[nextEditable]
            if not fixed[position] then nextEditable += 1 end
        end
        if same(order, final) then return true end
        order = final
        c.Value = table.clone(order)
        layout()
        if not silent then c:_emit(currentOrder()) end
        return true
    end
    local function createNode(item)
        local cell = create("Frame", {
            Name = "Priority_" .. item.Id, BackgroundColor3 = themeColor(theme, "Tile"),
            BackgroundTransparency = .84, Size = UDim2.new(1, 0, 0, rowStep - 2),
            Parent = scroll,
        }, { corner(6) })
        local num = text({ Name = "Position", Parent = cell, Text = "",
            FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
            Position = UDim2.fromOffset(7, 0), Size = UDim2.fromOffset(21, rowStep - 2) })
        local label = text({ Name = "Label", Parent = cell, Text = item.Label,
            TextSize = 12, TextColor3 = themeColor(theme, item.Disabled and "Muted" or "Text"),
            Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -148, 0, rowStep - 2),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local drag = create("TextButton", {
            Name = "DragHandle", Parent = cell, Text = "≡", AutoButtonColor = false,
            BackgroundTransparency = 1, TextSize = 17,
            TextColor3 = themeColor(theme, "SubText"),
            Position = UDim2.new(1, -112, 0, 0), Size = UDim2.fromOffset(34, rowStep - 2),
            Active = not item.Disabled, Visible = not item.Disabled,
        })
        local up = create("TextButton", {
            Name = "MoveUp", Parent = cell, Text = "↑", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "Field"),
            BackgroundTransparency = .25, TextSize = 15,
            TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.new(1, -76, 0, 3), Size = UDim2.fromOffset(36, 36),
        }, { corner(5) })
        local down = create("TextButton", {
            Name = "MoveDown", Parent = cell, Text = "↓", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "Field"),
            BackgroundTransparency = .25, TextSize = 15,
            TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.new(1, -38, 0, 3), Size = UDim2.fromOffset(36, 36),
        }, { corner(5) })
        local node = { Frame = cell, Pos = num, Label = label, DragHandle = drag,
            Up = up, Down = down, Connections = {} }
        nodes[item.Id] = node
        local function on(signal, fn)
            table.insert(node.Connections, signal:Connect(fn))
        end
        on(up.MouseButton1Click, function() c:Move(item.Id, (table.find(order, item.Id) or 1) - 1) end)
        on(down.MouseButton1Click, function() c:Move(item.Id, (table.find(order, item.Id) or 1) + 1) end)
        if not item.Disabled then
            local startY, target
            node.Drag = bindPointerDrag(hub, drag, {
                Start = function(input)
                    if not c:IsAvailable() then error("OrderList is unavailable") end
                    startY = input.Position.Y
                    target = table.find(order, item.Id)
                    setThemed(cell, "BackgroundColor3", themeColor(theme, "TileActive"))
                end,
                Move = function(input)
                    if not target then return end
                    local offset = math.floor(((input.Position.Y - startY) / math.max(hub._scale, .01)) / rowStep + .5)
                    target = math.clamp((table.find(order, item.Id) or 1) + offset, 1, #order)
                end,
                End = function(cancelled)
                    setThemed(cell, "BackgroundColor3", themeColor(theme, "Tile"))
                    if not cancelled and target then c:Move(item.Id, target) end
                    target = nil
                end,
            }, true)
        end
    end
    function c:GetOrder() return currentOrder() end
    function c:Get() return self:GetOrder() end
    function c:SetOrder(ids, silent)
        return setOrder(ids, silent, true)
    end
    c.Set = c.SetOrder
    function c:Move(id, index, silent)
        if not self:IsAvailable() then return false end
        local at = table.find(order, id)
        if not at or byId[id].Disabled then return false end
        index = math.clamp(math.floor(tonumber(index) or at), 1, #order)
        if at == index then return true end
        -- Block a move that would shift a fixed/disabled item.
        local low, high = math.min(at, index), math.max(at, index)
        for position = low, high do
            if byId[order[position]].Disabled then return false end
        end
        local nextOrder = currentOrder()
        table.remove(nextOrder, at)
        table.insert(nextOrder, index, id)
        return setOrder(nextOrder, silent, true)
    end
    function c:SetItems(nextItems, silent)
        local normalized, lookup = normalize(nextItems)
        local seen, nextOrder = {}, {}
        for _, id in order do
            if lookup[id] then table.insert(nextOrder, id); seen[id] = true end
        end
        for _, item in normalized do
            if not seen[item.Id] then table.insert(nextOrder, item.Id) end
        end
        teardownNodes()
        items, byId, order = normalized, lookup, nextOrder
        for _, item in items do createNode(item) end
        self.Value = currentOrder()
        layout()
        if not silent then self:_emit(currentOrder()) end
        return true
    end
    function c:OnOrderChanged(fn) return complexObserve(self, fn) end
    function c:Reset(silent) return self:SetOrder(self.DefaultValue or {}, silent) end
    function c:Destroy()
        if not live then return end
        live = false
        teardownNodes()
        complexForgetControl(self)
        row:Destroy()
    end
    hub:_connect(row.Destroying, function()
        live = false
        teardownNodes()
    end)
    c:SetItems(options.Items or {}, true)
    c.DefaultValue = type(options.Default) == "table" and table.clone(options.Default) or currentOrder()
    if type(options.Default) == "table" then
        local ok, err = c:SetOrder(options.Default, true)
        assert(ok, "OrderList.Default: " .. tostring(err))
    end
    return hub:_finishRequiredControl(c)
end

-- SPDX-License-Identifier: MPL-2.0
-- Paginated data grid with key-stable updates and touch-friendly horizontal scroll.
local function complexRowCopy(row)
    local out = {}
    for key, value in row do
        if type(value) == "table" then out[key] = table.clone(value)
        else out[key] = value end
    end
    return out
end

local function complexRowSnapshot(rows)
    local out = {}
    for i, row in rows do out[i] = complexRowCopy(row) end
    return out
end

local function complexCellValue(row, col)
    local cells = row.Cells or row.Values
    if type(cells) == "table" then
        local value = cells[col.Key]
        if value == nil then value = cells[col.Index] end
        return value
    end
    local value = row[col.Key]
    if value == nil then value = row[col.Index] end
    return value
end

function Section:DataTable(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local columns = {}
    for i, option in options.Columns or {} do
        local col = type(option) == "string" and { Key = option, Title = option } or table.clone(option)
        col.Key = tostring(col.Key or col.Id or col.Name or i)
        col.Title = complexString(col.Title or col.Name or col.Key)
        col.Index = i
        col.Width = math.clamp(math.floor(tonumber(col.Width) or 110), 65, 420)
        col.Align = (col.Align == "Right" or col.Align == "Center") and col.Align or "Left"
        col.Sortable = col.Sortable ~= false
        table.insert(columns, col)
    end
    assert(#columns > 0 and #columns <= 16, "DataTable requires 1–16 columns")
    local pageSize = math.clamp(math.floor(tonumber(options.PageSize) or 10), 3, 40)
    local bodyHeight = math.clamp(pageSize * 31 + 12, 105, 400)
    local minWidth = 0
    for _, col in columns do minWidth += col.Width end
    local showTitle = options.Name ~= nil
    local headerY = showTitle and 26 or 0
    local row = self:_row(headerY + 31 + bodyHeight + 32, "DataTable_" .. (options.Name or ""))
    local c = self:_control("DataTable", options, row)
    local alive, entries, byId, visible, nodes = true, {}, {}, {}, {}
    local widgetConnections = {}
    local function connect(signal, fn)
        local conn = signal:Connect(fn)
        table.insert(widgetConnections, conn)
        return conn
    end
    local function disconnectWidget()
        for _, conn in widgetConnections do conn:Disconnect() end
        table.clear(widgetConnections)
    end
    c.Rows = {}
    c.Columns = complexCloneList(columns)
    c.SelectedId = nil
    function c:GetSelection() return self.SelectedId end
    c.Page = 1
    c.Sort = nil
    c.Query = ""
    c.Loading = false
    c.Error = nil
    c.LayoutMode = options.LayoutMode or "Auto"
    assert(c.LayoutMode == "Auto" or c.LayoutMode == "Table" or c.LayoutMode == "Cards", "DataTable layout must be Auto, Table or Cards")
    c.EffectiveLayout = "Table"
    if showTitle then
        text({ Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
            FontFace = inter(Enum.FontWeight.SemiBold), TextTruncate = Enum.TextTruncate.AtEnd,
            Size = UDim2.new(1, 0, 0, 22) })
    end
    local shell = create("Frame", {
        Name = "TableShell", Parent = row, Position = UDim2.fromOffset(0, headerY),
        Size = UDim2.new(1, 0, 0, 31 + bodyHeight),
        BackgroundColor3 = themeColor(theme, "Field"), BackgroundTransparency = .16,
        ClipsDescendants = true,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke"), 1, .34) })
    local horizontal = create("ScrollingFrame", {
        Name = "HorizontalScroll", Parent = shell,
        Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
        BackgroundTransparency = 1, ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.fromOffset(minWidth + 10, 0),
    })
    local wide = create("Frame", {
        Name = "WideContent", BackgroundTransparency = 1,
        Size = UDim2.new(0, minWidth + 10, 1, -4), Parent = horizontal,
    })
    local head = create("Frame", {
        Name = "ColumnHeaders", BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .48, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30),
        Parent = wide,
    })
    local scroll = create("ScrollingFrame", {
        Name = "TableRows", Parent = wide, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 31), Size = UDim2.new(1, 0, 0, bodyHeight - 3),
        ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.None,
    })
    -- Mobile cards use a dedicated, bounded row pool. The table view is
    -- preserved in place so switching modes never rebuilds the data model.
    -- Compact cards display more records without sacrificing scroll gestures.
    -- CardHeight is optional for hubs with unusually long cell content.
    -- Even an explicit CardHeight must leave one readable line per column.
    local cardMinHeight = math.max(52, 12 + #columns * 18)
    local cardHeight = math.clamp(math.floor(tonumber(options.CardHeight) or cardMinHeight), cardMinHeight, 360)
    local cardLineHeight = (cardHeight - 12) / #columns
    local cardTools = create("Frame", {
        Name = "CardTools", Parent = shell, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30), Visible = false,
    })
    local cardSort = create("TextButton", {
        Name = "CardSort", Parent = cardTools, Text = "Sort",
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .3, AutoButtonColor = false,
        TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
        Position = UDim2.fromOffset(5, 2), Size = UDim2.new(1, -65, 0, 26),
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, { corner(6) })
    local cardDirection = create("TextButton", {
        Name = "CardDirection", Parent = cardTools, Text = "↑",
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .3, AutoButtonColor = false,
        TextColor3 = themeColor(theme, "SubText"), TextSize = 13,
        Position = UDim2.new(1, -54, 0, 2), Size = UDim2.fromOffset(48, 26),
    }, { corner(6) })
    local cardScroll = create("ScrollingFrame", {
        Name = "CardRows", Parent = shell, BackgroundTransparency = 1,
        BorderSizePixel = 0, Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, bodyHeight - 3),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
        CanvasSize = UDim2.new(), Visible = false,
    })
    local cardNodes = {}
    local touchStart, touchOrigin, touchMoved, touchBlockedUntil
    local function recordTouch(input)
        if input.UserInputType == Enum.UserInputType.Touch and not touchStart then
            touchStart = input
            touchOrigin = Vector2.new(input.Position.X, input.Position.Y)
            touchMoved = false
        end
    end
    -- Native scrolling remains active. Observe motion without capturing it
    -- so row taps are not fired after a drag or swipe.
    local function allowSelect()
        return touchStart == nil and (not touchBlockedUntil or os.clock() > touchBlockedUntil)
    end
    local status = text({
        Name = "EmptyState", Parent = shell, Text = options.EmptyText or "No data",
        TextSize = 12, TextColor3 = themeColor(theme, "Muted"),
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(4, headerY == -1 and 0 or 31),
        Size = UDim2.new(1, -8, 0, bodyHeight - 12), Visible = false,
    })
    local foot = create("Frame", {
        Name = "Pagination", Parent = row,
        Position = UDim2.fromOffset(0, headerY + bodyHeight + 32),
        Size = UDim2.new(1, 0, 0, 27), BackgroundTransparency = 1,
    })
    local info = text({
        Name = "PageInfo", Parent = foot, Text = "0 rows",
        TextColor3 = themeColor(theme, "SubText"), TextSize = 11,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -86, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local function pageButton(name, label, offset)
        return create("TextButton", {
            Name = name, Parent = foot, Text = label, AutoButtonColor = false,
            TextColor3 = themeColor(theme, "Text"), TextSize = 14,
            BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = .22,
            Position = UDim2.new(1, offset, 0, 0), Size = UDim2.fromOffset(38, 26),
        }, { corner(6) })
    end
    local back = pageButton("Previous", "‹", -81)
    local forward = pageButton("Next", "›", -39)
    local startX = 0
    for _, col in columns do
        local button = create("TextButton", {
            Name = "Sort_" .. col.Key, Parent = head, Text = col.Title,
            TextSize = 11, FontFace = inter(Enum.FontWeight.Medium),
            TextColor3 = themeColor(theme, col.Sortable and "Text" or "Muted"),
            TextXAlignment = col.Align == "Right" and Enum.TextXAlignment.Right
                or col.Align == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, AutoButtonColor = false,
            Position = UDim2.fromOffset(startX + 6, 0),
            Size = UDim2.fromOffset(col.Width - 10, 30),
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        startX += col.Width
        connect(button.MouseButton1Click, function()
            if col.Sortable then
                local nextDesc = c.Sort and c.Sort.Key == col.Key and not c.Sort.Descending
                c:SetSort(col.Key, nextDesc)
            end
        end)
    end

    local function rowId(value, index)
        if type(value) ~= "table" then return tostring(index) end
        return tostring(value.Id or value.Key or value.ID or index)
    end
    local function sortRows()
        visible = {}
        local needle = string.lower(c.Query)
        for _, item in entries do
            if needle == "" then table.insert(visible, item)
            else
                local found = false
                for _, col in columns do
                    local raw = complexCellValue(item, col)
                    if string.find(string.lower(complexString(raw)), needle, 1, true) then
                        found = true
                        break
                    end
                end
                if found then table.insert(visible, item) end
            end
        end
        if c.Sort then
            local col
            for _, candidate in columns do
                if candidate.Key == c.Sort.Key then col = candidate; break end
            end
            if col then
                table.sort(visible, function(a, b)
                    local av, bv = complexCellValue(a, col), complexCellValue(b, col)
                    -- Compare homogeneous types consistently. Mixed values use a
                    -- stable type bucket so sort remains a strict weak ordering.
                    local left, right = tonumber(av), tonumber(bv)
                    local aNumeric = type(av) == "number" or type(av) == "string" and left ~= nil
                    local bNumeric = type(bv) == "number" or type(bv) == "string" and right ~= nil
                    if aNumeric ~= bNumeric then
                        return aNumeric -- numbers are always above non-numbers
                    end
                    if aNumeric and bNumeric and left ~= right then
                        if c.Sort.Descending then return left > right end
                        return left < right
                    end
                    local sa, sb = string.lower(complexString(av)), string.lower(complexString(bv))
                    if sa ~= sb and (not aNumeric or not bNumeric) then
                        if c.Sort.Descending then return sa > sb end
                        return sa < sb
                    end
                    return a._index < b._index
                end)
            end
        end
    end
    local function destroyNode(node)
        for _, connection in node.Connections do connection:Disconnect() end
        node.Frame:Destroy()
    end
    local function paintNode(node, item)
        local sameItem = node.Id == item.Id
        node.Id = item.Id
        node.Frame.Name = "TableRow_" .. item.Id
        local tone = c.SelectedId == item.Id and .32 or .91
        local motionKey = "table-row:" .. tostring(node.Frame)
        if sameItem and node._targetTone ~= tone then
            Motion.play(hub, motionKey, node.Frame, { BackgroundTransparency = tone }, Motion.Presets.Micro)
        elseif not sameItem then
            Motion.cancel(hub, motionKey)
            node.Frame.BackgroundTransparency = tone
        end
        node._targetTone = tone
        for index, col in columns do
            local value = complexCellValue(item, col)
            local printable = complexString(value)
            if type(col.Format) == "function" then
                local ok, formatted = pcall(col.Format, value, item)
                if ok then printable = complexString(formatted) end
            end
            node.Cells[index].Text = printable
            setThemed(node.Cells[index], "TextColor3",
                themeColor(theme, c.SelectedId == item.Id and "Text" or "SubText"))
        end
    end
    local function makeNode(slot)
        local frame = create("TextButton", {
            Name = "TableRow", Parent = scroll, Text = "", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "TileActive"),
            BackgroundTransparency = .91, Size = UDim2.new(1, -6, 0, 29),
            Position = UDim2.fromOffset(2, (slot - 1) * 31 + 2),
        }, { corner(4) })
        local cells, colX = {}, 0
        for i, col in columns do
            cells[i] = text({ Name = "Cell_" .. col.Key, Parent = frame, Text = "",
                TextSize = 11, TextColor3 = themeColor(theme, "SubText"),
                TextXAlignment = col.Align == "Right" and Enum.TextXAlignment.Right
                    or col.Align == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
                Position = UDim2.fromOffset(colX + 7, 0),
                Size = UDim2.fromOffset(col.Width - 12, 29),
                TextTruncate = Enum.TextTruncate.AtEnd })
            colX += col.Width
        end
        local node = { Frame = frame, Cells = cells, Connections = {} }
        table.insert(node.Connections, frame.InputBegan:Connect(recordTouch))
        table.insert(node.Connections, frame.MouseButton1Click:Connect(function()
            if node.Id and c:IsAvailable() and options.Selectable ~= false
                and allowSelect() then
                c:Select(node.Id)
            end
        end))
        nodes[slot] = node
        return node
    end
    local function newCardSlot(slotId)
        local frame = create("TextButton", {
            Name = "TableCard", Parent = cardScroll, Text = "", AutoButtonColor = false,
            BackgroundColor3 = themeColor(theme, "TileActive"),
            BackgroundTransparency = .91, Size = UDim2.new(1, -8, 0, cardHeight - 3),
        }, { corner(6) })
        local fields = {}
        for i, col in columns do
            text({ Parent = frame, Name = "FieldName_" .. col.Key,
                Text = col.Title, TextSize = 10,
                TextColor3 = themeColor(theme, "SubText"),
                Position = UDim2.fromOffset(9, 5 + (i - 1) * cardLineHeight),
                Size = UDim2.new(.43, -12, 0, 17),
                TextTruncate = Enum.TextTruncate.AtEnd })
            fields[i] = text({ Parent = frame, Name = "FieldValue_" .. col.Key,
                Text = "", TextSize = 11,
                TextColor3 = themeColor(theme, "Text"),
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(.43, 0, 0, 5 + (i - 1) * cardLineHeight),
                Size = UDim2.new(.57, -10, 0, 17),
                TextTruncate = Enum.TextTruncate.AtEnd })
        end
        local node = { Frame = frame, Fields = fields, Id = nil }
        node.TouchConnection = frame.InputBegan:Connect(recordTouch)
        node.Connection = frame.MouseButton1Click:Connect(function()
            if node.Id and c:IsAvailable() and options.Selectable ~= false
                and allowSelect() then
                c:Select(node.Id)
            end
        end)
        cardNodes[slotId] = node
        return node
    end
    local function render()
        if not alive or hub._destroyed then return end
        local pages = math.max(1, math.ceil(#visible / pageSize))
        c.Page = math.clamp(c.Page, 1, pages)
        local start = (c.Page - 1) * pageSize + 1
        local count = math.min(pageSize, #visible - start + 1)
        count = math.max(0, count)
        local compact = c.EffectiveLayout == "Cards"
        horizontal.Visible = not compact
        cardTools.Visible = compact
        cardScroll.Visible = compact
        local sortKey = c.Sort and c.Sort.Key
        cardSort.Text = sortKey and ("Sort: " .. sortKey) or "Sort: none"
        cardDirection.Text = c.Sort and (c.Sort.Descending and "↓" or "↑") or "↑"
        cardDirection.Active = c.Sort ~= nil
        cardDirection.TextTransparency = c.Sort and 0 or .6
        if compact then
            cardScroll.CanvasSize = UDim2.fromOffset(0, count * cardHeight + 10)
            local maxInView = math.min(pageSize, math.ceil((bodyHeight - 3) / cardHeight) + 2)
            local first = math.clamp(math.floor(cardScroll.CanvasPosition.Y / math.max(cardHeight * hub._scale, 1)) + 1,
                1, math.max(1, count - maxInView + 1))
            for slot = 1, math.max(#cardNodes, math.min(count, maxInView)) do
                local item = slot <= maxInView and visible[start + first + slot - 2] or nil
                local node = cardNodes[slot]
                if item and start + first + slot - 2 <= start + count - 1 then
                    if not node then node = newCardSlot(slot) end
                    local sameItem = node.Id == item.Id
                    node.Id = item.Id
                    node.Frame.Visible = true
                    node.Frame.Position = UDim2.fromOffset(3, (first + slot - 2) * cardHeight + 2)
                    local tone = c.SelectedId == item.Id and .34 or .91
                    local motionKey = "table-card:" .. tostring(node.Frame)
                    if sameItem and node._targetTone ~= tone then
                        Motion.play(hub, motionKey, node.Frame, { BackgroundTransparency = tone }, Motion.Presets.Micro)
                    elseif not sameItem then
                        Motion.cancel(hub, motionKey)
                        node.Frame.BackgroundTransparency = tone
                    end
                    node._targetTone = tone
                    for index, col in columns do
                        local value = complexCellValue(item, col)
                        local printable = complexString(value)
                        if type(col.Format) == "function" then
                            local ok, formatted = pcall(col.Format, value, item)
                            if ok then printable = complexString(formatted) end
                        end
                        node.Fields[index].Text = printable
                    end
                elseif node then
                    node.Id = nil
                    node.Frame.Visible = false
                end
            end
            for _, node in nodes do
                node.Id = nil
                node.Frame.Visible = false
            end
        else
            for _, node in cardNodes do node.Frame.Visible = false end
            for slot = 1, math.max(#nodes, count) do
                local node = nodes[slot]
                if slot <= count then
                    if not node then node = makeNode(slot) end
                    local item = visible[start + slot - 1]
                    node.Frame.Visible = true
                    paintNode(node, item)
                elseif node then
                    node.Id = nil
                    node.Frame.Visible = false
                end
            end
        end
        scroll.CanvasSize = UDim2.fromOffset(0, count * 31 + 10)
        status.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No data"))
        status.Visible = c.Error ~= nil or c.Loading or #visible == 0
        scroll.Visible = not status.Visible
        if status.Visible then cardScroll.Visible = false end
        info.Text = string.format("%d / %d   ·   page %d/%d", #visible, #entries, c.Page, pages)
        back.Active = c.Page > 1
        forward.Active = c.Page < pages
        -- Hide inert arrows for one-page datasets and return their width to info.
        back.Visible = pages > 1
        forward.Visible = pages > 1
        info.Size = UDim2.new(1, pages > 1 and -86 or 0, 1, 0)
        back.TextTransparency = back.Active and 0 or .65
        forward.TextTransparency = forward.Active and 0 or .65
    end
    local function apply()
        scroll.CanvasPosition = Vector2.zero
        cardScroll.CanvasPosition = Vector2.zero
        sortRows()
        render()
    end
    local function resolveLayout()
        local nextMode = c.LayoutMode
        if nextMode == "Auto" then
            local width = row.AbsoluteSize.X / math.max(hub._scale, .01)
            -- Zero width during initial construction is not meaningful.
            nextMode = width > 0 and width < (tonumber(options.CompactBelow) or 300)
                and "Cards" or "Table"
        end
        if c.EffectiveLayout ~= nextMode then
            c.EffectiveLayout = nextMode
            scroll.CanvasPosition = Vector2.zero
            cardScroll.CanvasPosition = Vector2.zero
            render()
        end
    end
    function c:SetLayoutMode(mode)
        if mode ~= "Auto" and mode ~= "Table" and mode ~= "Cards" then
            return false, "expected Auto, Table or Cards"
        end
        self.LayoutMode = mode
        resolveLayout()
        return true
    end
    function c:GetLayoutMode() return self.EffectiveLayout end
    function c:Set(rows, silent)
        assert(type(rows) == "table", "DataTable:Set requires an array")
        local nextEntries, lookup = {}, {}
        for i, value in rows do
            local item = type(value) == "table" and complexRowCopy(value) or { Value = value }
            local id = rowId(item, i)
            assert(id ~= "" and not lookup[id], "DataTable requires unique row IDs")
            item.Id, item._index = id, i
            lookup[id] = item
            table.insert(nextEntries, item)
        end
        entries, byId = nextEntries, lookup
        if self.SelectedId and not lookup[self.SelectedId] then self.SelectedId = nil end
        self.Rows = complexRowSnapshot(entries)
        self.Page = 1
        apply()
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Set", Count = #entries })
        end
        return true
    end
    function c:Upsert(value, silent)
        assert(type(value) == "table" and (value.Id or value.Key), "DataTable:Upsert requires Id or Key")
        local id = tostring(value.Id or value.Key)
        local item = complexRowCopy(value)
        item.Id = id
        if byId[id] then
            item._index = byId[id]._index
            entries[item._index] = item
        else
            item._index = #entries + 1
            table.insert(entries, item)
        end
        byId[id] = item
        self.Rows = complexRowSnapshot(entries)
        apply()
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Upsert", Id = id })
        end
        return true
    end
    function c:Update(id, changes, silent)
        id = tostring(id)
        local old = byId[id]
        if not old or type(changes) ~= "table" then return false end
        local item = complexRowCopy(old)
        for key, value in changes do
            if key ~= "Id" and key ~= "_index" then
                if (key == "Cells" or key == "Values") and type(value) == "table" then
                    item[key] = item[key] and table.clone(item[key]) or {}
                    for ck, cv in value do item[key][ck] = cv end
                else item[key] = value end
            end
        end
        -- Preserve the existing one-callback behavior, but distinguish an
        -- in-place update from an Upsert in structured data events.
        if not self:Upsert(item, true) then return false end
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Update", Id = id })
        end
        return true
    end
    function c:Remove(id, silent)
        id = tostring(id)
        local old = byId[id]
        if not old then return false end
        table.remove(entries, old._index)
        byId[id] = nil
        for i, entry in entries do entry._index = i end
        if self.SelectedId == id then self.SelectedId = nil end
        self.Rows = complexRowSnapshot(entries)
        apply()
        if not silent then
            self:_emit(self:Get())
            self:_dataEvent("Data", { Operation = "Remove", Id = id })
        end
        return true
    end
    function c:Get()
        local results = complexRowSnapshot(entries)
        for _, item in results do item._index = nil end
        return results
    end
    function c:GetVisible()
        local results = complexRowSnapshot(visible)
        for _, item in results do item._index = nil end
        return results
    end
    function c:SetPage(page)
        page = tonumber(page)
        if not page or page ~= page or page == math.huge or page == -math.huge then
            return false
        end
        -- Clamp before publishing the event. A swipe beyond either end is a
        -- no-op instead of reporting a page that will never be displayed.
        local pageCount = math.max(1, math.ceil(#visible / pageSize))
        local nextPage = math.clamp(math.floor(page), 1, pageCount)
        if nextPage == self.Page then return true end
        self.Page = nextPage
        scroll.CanvasPosition = Vector2.zero
        cardScroll.CanvasPosition = Vector2.zero
        render()
        self:_dataEvent("Page", self.Page)
        return true
    end
    function c:SetSort(key, descending)
        if key == nil then self.Sort = nil
        else
            local found
            for _, col in columns do
                if col.Key == tostring(key) then
                    if not col.Sortable then return false end
                    found = true
                    break
                end
            end
            if not found then return false end
            self.Sort = { Key = tostring(key), Descending = descending == true }
        end
        self.Page = 1
        apply()
        self:_dataEvent("Sort", self.Sort and table.clone(self.Sort))
        return true
    end
    function c:SetQuery(query)
        self.Query = string.lower(complexString(query))
        self.Page = 1
        apply()
        self:_dataEvent("Filter", self.Query)
        return true
    end
    function c:Select(id, silent)
        id = id == nil and nil or tostring(id)
        if id and not byId[id] then return false end
        self.SelectedId = id
        render()
        if not silent and options.Selectable ~= false then
            self:_emit(id, id and complexRowCopy(byId[id]) or nil)
            self:_dataEvent("Selection", id)
        end
        return true
    end
    function c:SetLoading(value)
        self.Loading = value == true
        if self.Loading then self.Error = nil end
        render()
    end
    function c:SetError(message)
        self.Loading = false
        self.Error = message and tostring(message) or nil
        render()
    end
    function c:Clear() return self:Set({}, true) end
    function c:Destroy()
        if not alive then return end
        alive = false
        disconnectWidget()
        for _, node in nodes do destroyNode(node) end
        for _, node in cardNodes do
            node.Connection:Disconnect()
            node.TouchConnection:Disconnect()
            node.Frame:Destroy()
        end
        table.clear(nodes)
        table.clear(cardNodes)
        complexForgetControl(self)
        row:Destroy()
    end
    local sortable = {}
    for _, col in columns do
        if col.Sortable then table.insert(sortable, col.Key) end
    end
    connect(cardSort.MouseButton1Click, function()
        if #sortable == 0 then return end
        local index = c.Sort and table.find(sortable, c.Sort.Key) or nil
        local nextKey = sortable[(index and index % #sortable or 0) + 1]
        c:SetSort(nextKey, false)
    end)
    connect(cardDirection.MouseButton1Click, function()
        if c.Sort then c:SetSort(c.Sort.Key, not c.Sort.Descending) end
    end)
    -- Only track touches in data areas. Pagination and sorting gestures
    -- must never be interpreted as a card-page swipe.
    connect(cardScroll.InputBegan, recordTouch)
    connect(scroll.InputBegan, recordTouch)
    connect(UserInputService.InputChanged, function(input)
        if not alive or not touchStart or input ~= touchStart then return end
        local distance = (Vector2.new(input.Position.X, input.Position.Y) - touchOrigin).Magnitude
        if distance > 12 then
            touchMoved = true
            touchBlockedUntil = os.clock() + .22
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if not alive or not touchStart or input ~= touchStart then return end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - touchOrigin
        if math.abs(delta.X) > 65 and math.abs(delta.X) > math.abs(delta.Y) * 1.6
            and c.EffectiveLayout == "Cards" and options.SwipePaging ~= false then
            if delta.X < 0 then c:SetPage(c.Page + 1)
            else c:SetPage(c.Page - 1) end
            touchBlockedUntil = os.clock() + .3
        elseif delta.Magnitude > 12 then
            touchBlockedUntil = os.clock() + .22
        end
        touchStart, touchOrigin = nil, nil
    end)
    connect(back.MouseButton1Click, function()
        if c.Page > 1 then c:SetPage(c.Page - 1) end
    end)
    connect(forward.MouseButton1Click, function()
        if c.Page < math.ceil(#visible / pageSize) then c:SetPage(c.Page + 1) end
    end)
    connect(row.Destroying, function()
        alive = false
        disconnectWidget()
        for _, node in nodes do destroyNode(node) end
        for _, node in cardNodes do
            node.Connection:Disconnect()
            node.TouchConnection:Disconnect()
            node.Frame:Destroy()
        end
        table.clear(nodes)
        table.clear(cardNodes)
    end)
    connect(row:GetPropertyChangedSignal("AbsoluteSize"), resolveLayout)
    connect(cardScroll:GetPropertyChangedSignal("CanvasPosition"), function()
        if c.EffectiveLayout == "Cards" then render() end
    end)
    hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(shell:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
    hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
    c:Set(options.Rows or options.Items or {}, true)
    resolveLayout()
    return hub:_finishRequiredControl(c)
end

do
-- SPDX-License-Identifier: MPL-2.0
-- Read-only, keyed status records with bounded visible rows and incremental rendering.
local COMPLEX_STATUS_TONES = {
    healthy = "Success", online = "Success", success = "Success", ready = "Success",
    warning = "Warning", degraded = "Warning", pending = "Warning",
    error = "Danger", failed = "Danger", offline = "Danger",
    info = "SubText", idle = "Muted", unknown = "Muted",
}

local function complexStatusItem(value, index)
    assert(type(value) == "table", "StatusList items must be tables")
    local id = tostring(value.Id or value.Key or index)
    assert(id ~= "", "StatusList requires non-empty id")
    return {
        Id = id, Label = complexString(value.Label or value.Name or id),
        State = complexString(value.State or value.Status or "Unknown"),
        Detail = complexString(value.Detail or value.Description or ""),
        Tone = value.Tone or COMPLEX_STATUS_TONES[string.lower(complexString(value.State or value.Status or "unknown"))] or "SubText",
    }
end

function Section:StatusList(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 6), 2, 16)
    local rowHeight = 42
    local header = options.Name and 26 or 0
    local row = self:_row(header + rowHeight * math.min(maxVisible, 2) + 9,
        "StatusList_" .. (options.Name or "Statuses"))
    local c = self:_control("StatusList", options, row)
    local entries, byId, filtered, slots = {}, {}, {}, {}
    local alive = true
    c.Filter = "All"
    c.Loading = false
    c.Error = nil
    if options.Name then
        text({ Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
            FontFace = inter(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
    end
    local shell = create("Frame", {
        Name = "StatusBox", Parent = row, BackgroundColor3 = themeColor(theme, "Field"),
        BackgroundTransparency = .16,
        Position = UDim2.fromOffset(0, header),
        Size = UDim2.new(1, 0, 0, rowHeight * 2 + 8), ClipsDescendants = true,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke"), 1, .34) })
    local scroll = create("ScrollingFrame", {
        Name = "StatusRows", Parent = shell, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), ScrollBarThickness = 3,
        ScrollBarImageColor3 = themeColor(theme, "Knob"),
        ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(),
    })
    local message = text({ Name = "StatusMessage", Parent = shell,
        Text = options.EmptyText or "No statuses",
        TextColor3 = themeColor(theme, "Muted"), TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
        Visible = false })
    local function buildSlot(slot)
        local frame = create("Frame", {
            Name = "StatusRow", Parent = scroll,
            Position = UDim2.fromOffset(4, (slot - 1) * rowHeight + 3),
            Size = UDim2.new(1, -8, 0, rowHeight - 2),
            BackgroundColor3 = themeColor(theme, "Tile"),
            BackgroundTransparency = slot % 2 == 0 and .88 or .94,
        }, { corner(5) })
        local name = text({ Name = "Label", Parent = frame, Text = "",
            TextSize = 12, TextColor3 = themeColor(theme, "Text"),
            Position = UDim2.fromOffset(9, 3), Size = UDim2.new(1, -105, 0, 18),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local detail = text({ Name = "Detail", Parent = frame, Text = "",
            TextSize = 10, TextColor3 = themeColor(theme, "SubText"),
            Position = UDim2.fromOffset(9, 21), Size = UDim2.new(1, -18, 0, 15),
            TextTruncate = Enum.TextTruncate.AtEnd })
        local badge = create("Frame", {
            Name = "Badge", Parent = frame,
            BackgroundColor3 = themeColor(theme, "TileActive"),
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -7, 0, 5),
            Size = UDim2.fromOffset(86, 21),
        }, { corner(6) })
        local value = text({ Name = "State", Parent = badge, Text = "",
            TextSize = 10, FontFace = inter(Enum.FontWeight.Medium),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextColor3 = themeColor(theme, "SubText"),
            Size = UDim2.fromScale(1, 1), TextTruncate = Enum.TextTruncate.AtEnd })
        slots[slot] = { Frame = frame, Label = name, Detail = detail, State = value, Badge = badge, Id = nil }
    end
    local function listFilter()
        filtered = {}
        for _, item in entries do
            local tone = COMPLEX_STATUS_TONES[string.lower(item.State)] or item.Tone
            if c.Filter == "All" or c.Filter == item.State or c.Filter == tone then
                table.insert(filtered, item)
            end
        end
    end
    local function render()
        if not alive or hub._destroyed then return end
        listFilter()
        local count = #filtered
        local visible = math.min(maxVisible, math.max(2, count))
        shell.Size = UDim2.new(1, 0, 0, visible * rowHeight + 8)
        row.Size = UDim2.new(1, 0, 0, header + visible * rowHeight + 8)
        message.Visible = c.Error ~= nil or c.Loading or count == 0
        message.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No statuses"))
        scroll.Visible = not message.Visible
        -- Render the first bounded batch. For large sets use native ScrollingFrame
        -- CanvasPosition as the virtualization source; offscreen instances are pooled.
        scroll.CanvasSize = UDim2.fromOffset(0, count * rowHeight + 12)
        local first = math.clamp(math.floor(scroll.CanvasPosition.Y / math.max(rowHeight * hub._scale, 1)) + 1,
            1, math.max(1, count - maxVisible + 1))
        local slotCount = math.min(count, maxVisible + 2)
        for slot = 1, math.max(slotCount, #slots) do
            local item = slot <= slotCount and filtered[first + slot - 1] or nil
            local record = slots[slot]
            if item then
                if not record then buildSlot(slot); record = slots[slot] end
                record.Frame.Visible = true
                record.Frame.Position = UDim2.fromOffset(4, (first + slot - 2) * rowHeight + 3)
                local compact = scroll.AbsoluteSize.X / math.max(hub._scale, .01) < 230
                record.Badge.Size = UDim2.fromOffset(compact and 65 or 86, 21)
                record.Label.Size = UDim2.new(1, compact and -83 or -105, 0, 18)
                if record.Id ~= item.Id or record.Label.Text ~= item.Label then record.Label.Text = item.Label end
                if record.Detail.Text ~= item.Detail then record.Detail.Text = item.Detail end
                if record.State.Text ~= item.State then record.State.Text = item.State end
                setThemed(record.State, "TextColor3", themeColor(theme, item.Tone))
                record.Id = item.Id
            elseif record then
                record.Frame.Visible = false
                record.Id = nil
            end
        end
    end
    function c:Set(items)
        assert(type(items) == "table", "StatusList:Set requires array")
        local all, lookup = {}, {}
        for i, value in items do
            local item = complexStatusItem(value, i)
            assert(not lookup[item.Id], "StatusList duplicate id: " .. item.Id)
            table.insert(all, item)
            lookup[item.Id] = item
        end
        entries, byId = all, lookup
        render()
        c:_dataEvent("Data", { Operation = "Set", Count = #entries })
        return true
    end
    function c:Upsert(item)
        assert(type(item) == "table" and (item.Id or item.Key), "StatusList:Upsert requires Id or Key")
        local id = tostring(item.Id or item.Key)
        local previous = byId[id]
        local updated = complexStatusItem(item, id)
        if previous then
            for k, v in updated do previous[k] = v end
        else
            byId[id] = updated
            table.insert(entries, updated)
        end
        render()
        c:_dataEvent("Data", { Operation = "Upsert", Id = id })
        return true
    end
    function c:Update(id, value)
        local item = byId[tostring(id)]
        if not item or type(value) ~= "table" then return false end
        if value.Label ~= nil then item.Label = complexString(value.Label) end
        if value.State ~= nil or value.Status ~= nil then
            item.State = complexString(value.State or value.Status)
            if value.Tone == nil then
                item.Tone = COMPLEX_STATUS_TONES[string.lower(item.State)] or "SubText"
            end
        end
        if value.Detail ~= nil then item.Detail = complexString(value.Detail) end
        if value.Tone ~= nil then item.Tone = tostring(value.Tone) end
        render()
        c:_dataEvent("Data", { Operation = "Update", Id = tostring(id) })
        return true
    end
    function c:Remove(id)
        id = tostring(id)
        local item = byId[id]
        if not item then return false end
        byId[id] = nil
        local position = table.find(entries, item)
        if position then table.remove(entries, position) end
        render()
        c:_dataEvent("Data", { Operation = "Remove", Id = id })
        return true
    end
    function c:SetFilter(filter)
        self.Filter = filter and tostring(filter) or "All"
        scroll.CanvasPosition = Vector2.zero
        render()
        c:_dataEvent("Filter", self.Filter)
        return true
    end
    function c:SetLoading(value)
        self.Loading = value == true
        if self.Loading then self.Error = nil end
        render()
    end
    function c:SetError(err)
        self.Loading = false
        self.Error = err and tostring(err) or nil
        render()
    end
    function c:Get()
        return complexRowSnapshot(entries)
    end
    function c:Clear() return self:Set({}) end
    function c:Destroy()
        if not alive then return end
        alive = false
        complexForgetControl(self)
        row:Destroy()
    end
    hub:_connect(scroll:GetPropertyChangedSignal("CanvasPosition"), render)
    hub:_connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), render)
    hub:_connect(row.Destroying, function()
        alive = false
        table.clear(slots)
    end)
    hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(shell:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
    hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
    c:Set(options.Items or {})
    return hub:_finishRequiredControl(c)
end

end
-- SPDX-License-Identifier: MPL-2.0
-- Bounded, read-only event feed for diagnostics, activity and operation history.
-- Keeps data separate from pooled GUI rows and never starts a frame loop.
do
    local EVENT_TONES = {
        info = "SubText", success = "Success", warning = "Warning",
        error = "Danger", danger = "Danger", debug = "Muted",
    }
    local function eventCopy(event)
        return {
            Id = tostring(event.Id or event.Key),
            Title = tostring(event.Title or event.Name or "Event"),
            Detail = tostring(event.Detail or event.Description or ""),
            Category = tostring(event.Category or "Info"),
            Time = event.Time,
            Tone = event.Tone,
        }
    end
    function Section:EventTimeline(options)
        options = type(options) == "table" and options or {}
        local hub, theme = self.Hub, self.Hub.Theme
        local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 5), 2, 12)
        local maxRecords = math.clamp(math.floor(tonumber(options.MaxRecords) or 300), 10, 2000)
        local lineHeight = 52
        local headerHeight = options.Name and 26 or 0
        local row = self:_row(headerHeight + maxVisible * lineHeight + 12,
            "EventTimeline_" .. tostring(options.Name or "Events"))
        local c = self:_control("EventTimeline", options, row)
        local items, byId, filtered, slots = {}, {}, {}, {}
        local alive, serial = true, 0
        c.Filter, c.Paused, c.Loading, c.Error = "All", false, false, nil
        if options.Name then
            text({ Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
                FontFace = inter(Enum.FontWeight.SemiBold), TextTruncate = Enum.TextTruncate.AtEnd,
                Size = UDim2.new(1, 0, 0, 21) })
        end
        local shell = create("Frame", {
            Name = "TimelineShell", Parent = row, Position = UDim2.fromOffset(0, headerHeight),
            BackgroundColor3 = themeColor(theme, "Field"),
            Size = UDim2.new(1, 0, 0, maxVisible * lineHeight + 8),
            ClipsDescendants = true,
        }, { corner(8), stroke(themeColor(theme, "FieldStroke")) })
        local scroll = create("ScrollingFrame", {
            Name = "TimelineScroll", Parent = shell, BackgroundTransparency = 1,
            BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
            ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
            ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(),
        })
        local message = text({ Name = "TimelineMessage", Parent = shell,
            Text = options.EmptyText or "No events", TextColor3 = themeColor(theme, "Muted"),
            TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.fromScale(1, 1), Visible = false })
        local function makeSlot(n)
            local frame = create("Frame", {
                Name = "TimelineEvent", Parent = scroll, BackgroundColor3 = themeColor(theme, "Tile"),
                BackgroundTransparency = n % 2 == 0 and .68 or .78,
                Size = UDim2.new(1, -9, 0, lineHeight - 3),
            }, { corner(5) })
            local dot = create("Frame", { Name = "Tone", Parent = frame,
                BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0,
                Position = UDim2.fromOffset(8, 12), Size = UDim2.fromOffset(6, 6),
            }, { corner(100) })
            local title = text({ Name = "EventTitle", Parent = frame, Text = "",
                TextColor3 = themeColor(theme, "Text"), TextSize = 12,
                Position = UDim2.fromOffset(21, 5), Size = UDim2.new(1, -105, 0, 18),
                TextTruncate = Enum.TextTruncate.AtEnd })
            local detail = text({ Name = "EventDetail", Parent = frame, Text = "",
                TextColor3 = themeColor(theme, "Muted"), TextSize = 10,
                Position = UDim2.fromOffset(21, 25), Size = UDim2.new(1, -29, 0, 17),
                TextTruncate = Enum.TextTruncate.AtEnd })
            local stamp = text({ Name = "EventTime", Parent = frame, Text = "",
                TextColor3 = themeColor(theme, "SubText"), TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -87, 0, 5), Size = UDim2.fromOffset(80, 18) })
            slots[n] = { Frame = frame, Dot = dot, Title = title, Detail = detail, Stamp = stamp }
        end
        local function visibleItems()
            filtered = {}
            for _, item in items do
                if c.Filter == "All" or c.Filter == item.Category then
                    table.insert(filtered, item)
                end
            end
        end
        local function render()
            if not alive or hub._destroyed then return end
            visibleItems()
            local count = #filtered
            local height = math.min(maxVisible, math.max(2, count)) * lineHeight + 8
            shell.Size = UDim2.new(1, 0, 0, height)
            row.Size = UDim2.new(1, 0, 0, headerHeight + height + 5)
            scroll.CanvasSize = UDim2.fromOffset(0, count * lineHeight + 8)
            message.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No events"))
            message.Visible = c.Error ~= nil or c.Loading or count == 0
            scroll.Visible = not message.Visible
            local first = math.clamp(math.floor(scroll.CanvasPosition.Y / math.max(lineHeight * hub._scale, 1)) + 1,
                1, math.max(1, count - maxVisible + 1))
            local total = math.min(count, maxVisible + 2)
            for i = 1, math.max(total, #slots) do
                local item = i <= total and filtered[first + i - 1] or nil
                local slot = slots[i]
                if item then
                    if not slot then makeSlot(i); slot = slots[i] end
                    slot.Frame.Visible = true
                    slot.Frame.Position = UDim2.fromOffset(4, (first + i - 2) * lineHeight + 3)
                    slot.Title.Text, slot.Detail.Text = item.Title, item.Detail
                    slot.Stamp.Text = item.Time == nil and "" or tostring(item.Time)
                    local tone = item.Tone or EVENT_TONES[string.lower(item.Category)] or "SubText"
                    if not theme[tone] then tone = "SubText" end
                    setThemed(slot.Dot, "BackgroundColor3", themeColor(theme, tone))
                elseif slot then
                    slot.Frame.Visible = false
                end
            end
        end
        local function insert(item)
            serial += 1
            local source = table.clone(item)
            source.Id = source.Id or source.Key or ("event-" .. serial)
            local entry = eventCopy(source)
            assert(entry.Id ~= "" and not byId[entry.Id], "EventTimeline requires unique event IDs")
            table.insert(items, entry)
            byId[entry.Id] = entry
            while #items > maxRecords do
                local removed = table.remove(items, 1)
                byId[removed.Id] = nil
            end
        end
        function c:Append(event)
            if not alive then return false end
            assert(type(event) == "table", "EventTimeline:Append requires event table")
            insert(event)
            if not self.Paused then render() end
            self:_dataEvent("Data", { Operation = "Append", Id = tostring(event.Id or event.Key or ("event-" .. serial)) })
            return true
        end
        function c:Set(events)
            if not alive then return false end
            assert(type(events) == "table", "EventTimeline:Set requires array")
            local nextItems, nextLookup, nextSerial = {}, {}, serial
            for _, event in events do
                assert(type(event) == "table", "EventTimeline item must be a table")
                nextSerial += 1
                local source = table.clone(event)
                source.Id = source.Id or source.Key or ("event-" .. nextSerial)
                local item = eventCopy(source)
                assert(item.Id ~= "" and not nextLookup[item.Id], "EventTimeline duplicate ID")
                table.insert(nextItems, item)
                nextLookup[item.Id] = item
            end
            while #nextItems > maxRecords do
                local removed = table.remove(nextItems, 1)
                nextLookup[removed.Id] = nil
            end
            items, byId, serial = nextItems, nextLookup, nextSerial
            if not self.Paused then render() end
            return true
        end
        function c:Get()
            local result = {}
            for i, item in items do result[i] = table.clone(item) end
            return result
        end
        function c:Remove(id)
            id = tostring(id)
            local item = byId[id]
            if not item then return false end
            byId[id] = nil
            local index = table.find(items, item)
            if index then table.remove(items, index) end
            if not self.Paused then render() end
            return true
        end
        function c:SetFilter(category)
            self.Filter = category and tostring(category) or "All"
            scroll.CanvasPosition = Vector2.zero
            render()
            self:_dataEvent("Filter", self.Filter)
            return true
        end
        function c:SetPaused(value)
            self.Paused = value == true
            if not self.Paused then render() end
        end
        function c:SetLoading(value)
            self.Loading = value == true
            if self.Loading then self.Error = nil end
            render()
        end
        function c:SetError(value)
            self.Loading = false
            self.Error = value == nil and nil or tostring(value)
            render()
        end
        function c:Clear() return self:Set({}) end
        function c:Destroy()
            if not alive then return end
            alive = false
            complexForgetControl(self)
            row:Destroy()
        end
        hub:_connect(scroll:GetPropertyChangedSignal("CanvasPosition"), render)
        hub:_connect(row.Destroying, function()
            alive = false
            table.clear(slots)
        end)
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
        hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
        c:Set(options.Events or options.Items or {})
        return hub:_finishRequiredControl(c)
    end
end

-- SPDX-License-Identifier: MPL-2.0
-- RelaxUI TreeView: nested, keyed data with reusable visible rows.
-- Never creates GUI rows for off-screen nodes or starts a frame loop.
do
    local function treeSnapshot(nodes)
        local result = {}
        for i, node in nodes do
            result[i] = {
                Id = node.Id, Label = node.Label, Detail = node.Detail,
                Badge = node.Badge, Disabled = node.Disabled,
                Children = treeSnapshot(node.Children),
            }
        end
        return result
    end

    function Section:TreeView(options)
        options = type(options) == "table" and options or {}
        local hub, theme = self.Hub, self.Hub.Theme
        local maxVisible = math.clamp(math.floor(tonumber(options.MaxVisible) or 6), 2, 14)
        local rowHeight = 41
        local header = options.Name and 26 or 0
        local row = self:_row(header + rowHeight * 2 + 10,
            "TreeView_" .. tostring(options.Name or "Tree"))
        local c = self:_control("TreeView", options, row)
        local roots, byId, expanded, flattened, slots = {}, {}, {}, {}, {}
        local connections = {}
        local alive = true
        c.Query, c.SelectedId = "", nil
        c.Loading, c.Error = false, nil
        local persistKey = self.Id .. "/tree/" .. tostring(options.Id or options.Flag or c.Name)
        local savedState = options.Persist ~= false and hub.SetupData
            and type(hub.SetupData.TreeStates) == "table"
            and hub.SetupData.TreeStates[persistKey] or nil
        local restoring = true
        local pendingWrite, writeScheduled = false, false
        c.PersistKey = persistKey
        c.Persist = options.Persist ~= false

        local function connect(signal, callback)
            local conn = signal:Connect(callback)
            table.insert(connections, conn)
            return conn
        end
        if options.Name then
            text({
                Name = "Title", Parent = row, Text = c.Name, TextSize = 13,
                FontFace = inter(Enum.FontWeight.SemiBold),
                TextColor3 = themeColor(theme, "Text"),
                Size = UDim2.new(1, 0, 0, 21),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
        end
        local shell = create("Frame", {
            Name = "TreeShell", Parent = row,
            Position = UDim2.fromOffset(0, header),
            BackgroundColor3 = themeColor(theme, "Field"), BackgroundTransparency = .16,
            Size = UDim2.new(1, 0, 0, rowHeight * 2 + 8),
            ClipsDescendants = true,
        }, { corner(8), stroke(themeColor(theme, "FieldStroke"), 1, .34) })
        local scroll = create("ScrollingFrame", {
            Name = "TreeRows", Parent = shell,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
            CanvasSize = UDim2.new(),
        })
        local empty = text({
            Name = "TreeMessage", Parent = shell, Text = options.EmptyText or "No items",
            TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
            TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1),
            Visible = false,
        })
        local function normalize(nodes)
            assert(type(nodes) == "table", "TreeView nodes must be an array")
            local index, active, initial = {}, {}, {}
            local count = 0
            local function visit(items, depth, parentId)
                assert(depth <= 14, "TreeView depth exceeds 14")
                assert(type(items) == "table", "TreeView Children must be an array")
                assert(not active[items], "TreeView cyclic child table")
                active[items] = true
                local out = {}
                for i, value in items do
                    assert(type(value) == "table", "TreeView nodes must be tables")
                    count += 1
                    assert(count <= 4096, "TreeView supports up to 4096 nodes")
                    local id = value.Id or value.Key
                    assert(id ~= nil and tostring(id) ~= "", "TreeView requires node IDs")
                    id = tostring(id)
                    assert(not index[id], "TreeView duplicate ID: " .. id)
                    local node = {
                        Id = id,
                        Label = tostring(value.Label or value.Name or id),
                        Detail = value.Detail == nil and "" or tostring(value.Detail),
                        Badge = value.Badge == nil and "" or tostring(value.Badge),
                        Disabled = value.Disabled == true,
                        ParentId = parentId,
                        Depth = depth,
                        Children = {},
                    }
                    index[id] = node
                    table.insert(out, node)
                    local children = value.Children or {}
                    node.Children = visit(children, depth + 1, id)
                    if #node.Children > 0 then
                        initial[id] = value.Expanded ~= nil and value.Expanded == true
                            or (value.Expanded == nil and depth == 0 and options.ExpandRoots ~= false)
                    end
                end
                active[items] = nil
                return out
            end
            return visit(nodes, 0, nil), index, initial
        end
        local function makeSlot(slotId)
            local frame = create("Frame", {
                Name = "TreeRow", Parent = scroll,
                BackgroundColor3 = themeColor(theme, "Tile"),
                BackgroundTransparency = .91,
                Size = UDim2.new(1, -9, 0, rowHeight - 2),
            }, { corner(5) })
            -- Reused row slots keep a faint depth rail, avoiding another nested black card.
            local depthRail = create("Frame", {
                Name = "DepthRail", Parent = frame, BorderSizePixel = 0,
                BackgroundColor3 = themeColor(theme, "SubText"),
                BackgroundTransparency = .78, Visible = false,
                Position = UDim2.fromOffset(13, 8), Size = UDim2.fromOffset(1, rowHeight - 18),
            })
            local toggle = create("TextButton", {
                Name = "Expand", Parent = frame, Text = "",
                AutoButtonColor = false, BackgroundTransparency = 1,
                TextColor3 = themeColor(theme, "SubText"), TextSize = 15,
                Size = UDim2.fromOffset(24, rowHeight - 2),
            })
            -- Asset chevrons do not depend on Android's glyph fallback.
            local arrow = iconLabel("chevron-right", 14, theme.SubText, {
                Parent = toggle, AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5), ZIndex = 3,
            })
            local selectButton = create("TextButton", {
                Name = "Select", Parent = frame, Text = "",
                AutoButtonColor = false, BackgroundTransparency = 1,
                Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0),
            })
            local label = text({
                Name = "TreeLabel", Parent = selectButton, Text = "",
                TextSize = 12, TextColor3 = themeColor(theme, "Text"),
                Position = UDim2.fromOffset(0, 2),
                Size = UDim2.new(1, -86, 0, 18),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local detail = text({
                Name = "TreeDetail", Parent = selectButton, Text = "",
                TextSize = 10, TextColor3 = themeColor(theme, "SubText"),
                Position = UDim2.fromOffset(0, 20),
                Size = UDim2.new(1, -8, 0, 15),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local badge = text({
                Name = "TreeBadge", Parent = selectButton, Text = "",
                TextSize = 10, TextColor3 = themeColor(theme, "SubText"),
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2.new(1, -82, 0, 3),
                Size = UDim2.fromOffset(76, 17),
                TextTruncate = Enum.TextTruncate.AtEnd,
            })
            local slot = {
                Frame = frame, DepthRail = depthRail, Toggle = toggle, Arrow = arrow, Select = selectButton,
                Label = label, Detail = detail, Badge = badge, Id = nil,
            }
            slots[slotId] = slot
            connect(toggle.MouseButton1Click, function()
                if slot.Id and c:IsAvailable() then c:SetExpanded(slot.Id, not expanded[slot.Id]) end
            end)
            connect(selectButton.MouseButton1Click, function()
                if slot.Id and c:IsAvailable() then c:Select(slot.Id) end
            end)
            return slot
        end
        local function rebuild()
            flattened = {}
            local query = string.lower(c.Query)
            local matching = {}
            if query ~= "" then
                local function contains(node)
                    local found = string.find(string.lower(node.Label), query, 1, true) ~= nil
                        or string.find(string.lower(node.Detail), query, 1, true) ~= nil
                        or string.find(string.lower(node.Badge), query, 1, true) ~= nil
                    for _, child in node.Children do
                        if contains(child) then found = true end
                    end
                    matching[node.Id] = found
                    return found
                end
                for _, root in roots do contains(root) end
            end
            local function append(nodes)
                for _, node in nodes do
                    if query == "" or matching[node.Id] then
                        table.insert(flattened, node)
                        if query ~= "" or expanded[node.Id] then append(node.Children) end
                    end
                end
            end
            append(roots)
        end
        local function render()
            if not alive or hub._destroyed then return end
            local count = #flattened
            local visibleCount = math.min(maxVisible, math.max(2, count))
            local height = visibleCount * rowHeight + 8
            shell.Size = UDim2.new(1, 0, 0, height)
            row.Size = UDim2.new(1, 0, 0, header + height + 5)
            scroll.CanvasSize = UDim2.fromOffset(0, count * rowHeight + 12)
            empty.Text = c.Error or (c.Loading and "Loading…" or (options.EmptyText or "No items"))
            empty.Visible = c.Error ~= nil or c.Loading or count == 0
            scroll.Visible = not empty.Visible
            local first = math.clamp(
                math.floor(scroll.CanvasPosition.Y / math.max(rowHeight * hub._scale, 1)) + 1,
                1, math.max(1, count - maxVisible + 1))
            local amount = math.min(count, maxVisible + 2)
            for i = 1, math.max(#slots, amount) do
                local node = i <= amount and flattened[first + i - 1] or nil
                local slot = slots[i]
                if node then
                    if not slot then slot = makeSlot(i) end
                    local sameNode = slot.Id == node.Id
                    slot.Id = node.Id
                    slot.Frame.Visible = true
                    slot.Frame.Position = UDim2.fromOffset(4, (first + i - 2) * rowHeight + 3)
                    -- Keep a minimum readable label area at deep levels on mobile.
                    local logicalWidth = math.max(0, scroll.AbsoluteSize.X / math.max(hub._scale, .01))
                    local indent = math.min(node.Depth * 12, math.max(0, logicalWidth - 180))
                    local hasChildren = #node.Children > 0
                    slot.Toggle.Visible = hasChildren
                    slot.Toggle.Position = UDim2.fromOffset(indent + 2, 0)
                    slot.Toggle.Text = ""
                    if slot.Arrow then
                        slot.Arrow.Visible = hasChildren
                        local targetAngle = (expanded[node.Id] or c.Query ~= "") and 90 or 0
                        local arrowKey = "tree-arrow:" .. tostring(slot.Toggle)
                        if sameNode and slot._targetAngle ~= targetAngle then
                            Motion.play(hub, arrowKey, slot.Arrow, { Rotation = targetAngle }, Motion.Presets.Micro)
                        elseif not sameNode then
                            Motion.cancel(hub, arrowKey)
                            slot.Arrow.Rotation = targetAngle
                        end
                    end
                    slot._targetAngle = (expanded[node.Id] or c.Query ~= "") and 90 or 0
                    slot.DepthRail.Visible = node.Depth > 0
                    slot.DepthRail.Position = UDim2.fromOffset(math.max(8, indent - 5), 8)
                    slot.Label.FontFace = inter(node.Depth == 0 and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular)
                    slot.Select.Position = UDim2.fromOffset(indent + 26, 0)
                    slot.Select.Size = UDim2.new(1, -indent - 26, 1, 0)
                    -- Badge competes with labels on narrow panels; hide it, not the title.
                    local showBadge = logicalWidth >= 245 and node.Badge ~= ""
                    slot.Badge.Visible = showBadge
                    slot.Label.Size = UDim2.new(1, showBadge and -86 or -8, 0, 18)
                    slot.Label.Text = node.Label
                    slot.Detail.Text = node.Detail
                    slot.Badge.Text = node.Badge
                    local rowTone = c.SelectedId == node.Id and .32
                        or (node.Depth == 0 and .72 or .86)
                    local toneKey = "tree-row:" .. tostring(slot.Frame)
                    if sameNode and slot._targetTone ~= rowTone then
                        Motion.play(hub, toneKey, slot.Frame, { BackgroundTransparency = rowTone }, Motion.Presets.Micro)
                    elseif not sameNode then
                        Motion.cancel(hub, toneKey)
                        slot.Frame.BackgroundTransparency = rowTone
                    end
                    slot._targetTone = rowTone
                    setThemed(slot.Label, "TextColor3",
                        themeColor(theme, node.Disabled and "Muted" or "Text"))
                    setThemed(slot.Detail, "TextColor3",
                        themeColor(theme, node.Disabled and "Muted" or "SubText"))
                elseif slot then
                    slot.Id = nil
                    slot.Frame.Visible = false
                end
            end
        end
        local function refresh()
            rebuild()
            render()
        end
        local function stateSnapshot()
            return { Version = 1, Expanded = table.clone(expanded), SelectedId = c.SelectedId }
        end
        local function flushPersistence()
            if not pendingWrite or hub._destroyed then return false end
            pendingWrite = false
            hub:_savePref("TreeStates", hub.SetupData.TreeStates)
            return true
        end
        function c:FlushState()
            return flushPersistence()
        end
        local function persistState()
            if restoring or options.Persist == false or hub._replaying or hub._destroyed then return end
            hub.SetupData = hub.SetupData or {}
            local prefs = hub.SetupData.TreeStates
            if type(prefs) ~= "table" then
                prefs = {}
                hub.SetupData.TreeStates = prefs
            end
            prefs[persistKey] = stateSnapshot()
            pendingWrite = true
            -- Mutate the in-memory snapshot immediately, but coalesce disk writes
            -- while the user expands or selects several nodes in rapid succession.
            if not writeScheduled then
                writeScheduled = true
                task.delay(.35, function()
                    writeScheduled = false
                    if alive and not hub._destroyed then flushPersistence() end
                end)
            end
        end
        local function stateChanged(kind, payload, silent)
            c.Value = stateSnapshot()
            persistState()
            if not silent then
                c:_dataEvent(kind, payload)
                c:_dataEvent("State", c:GetState())
            end
        end
        function c:GetState() return stateSnapshot() end
        function c:GetSelection() return self.SelectedId end
        function c:OnStateChanged(fn)
            return self:OnDataEvent("State", fn)
        end
        function c:SetState(state, silent)
            if not alive then return false, "destroyed" end
            if type(state) ~= "table" then return false, "state must be a table" end
            if state.Expanded ~= nil and type(state.Expanded) ~= "table" then
                return false, "Expanded must be a map"
            end
            if state.SelectedId ~= nil and type(state.SelectedId) ~= "string" then
                return false, "SelectedId must be a string"
            end
            local nextExpanded = table.clone(expanded)
            for id, value in state.Expanded or {} do
                if type(id) ~= "string" or type(value) ~= "boolean" then
                    return false, "Expanded must contain string IDs and boolean states"
                end
                if nextExpanded[id] ~= nil then nextExpanded[id] = value end
            end
            local chosen = state.SelectedId
            if chosen ~= nil and (not byId[chosen] or byId[chosen].Disabled) then chosen = nil end
            expanded = nextExpanded
            self.SelectedId = chosen
            refresh()
            stateChanged("StateRestored", self:GetState(), silent)
            return true
        end
        function c:SetNodes(nodes)
            if not alive then return false end
            -- Build the replacement completely before touching live state.
            local newRoots, newIndex, defaults = normalize(nodes)
            local newExpanded = {}
            for id, default in defaults do
                newExpanded[id] = expanded[id] == nil and default or expanded[id]
            end
            roots, byId, expanded = newRoots, newIndex, newExpanded
            if self.SelectedId and (not byId[self.SelectedId] or byId[self.SelectedId].Disabled) then self.SelectedId = nil end
            scroll.CanvasPosition = Vector2.zero
            refresh()
            stateChanged("Data", { Operation = "SetNodes", Count = #flattened }, restoring)
            return true
        end
        c.Set = c.SetNodes
        function c:GetTree() return treeSnapshot(roots) end
        function c:Get() return self:GetTree() end
        function c:GetVisible()
            local result = {}
            for i, node in flattened do
                result[i] = { Id = node.Id, Label = node.Label, Depth = node.Depth }
            end
            return result
        end
        function c:GetExpanded(id)
            if id ~= nil then return expanded[tostring(id)] == true end
            return table.clone(expanded)
        end
        function c:SetExpanded(id, value)
            id = tostring(id)
            local node = byId[id]
            if not node or #node.Children == 0 then return false end
            local nextState = value == true
            if expanded[id] ~= nextState then
                expanded[id] = nextState
                refresh()
                stateChanged("Expansion", { Id = id, Expanded = nextState })
            end
            return true
        end
        function c:ExpandAll()
            for id in expanded do expanded[id] = true end
            refresh()
            stateChanged("Expansion", { All = true, Expanded = true })
            return true
        end
        function c:CollapseAll()
            for id in expanded do expanded[id] = false end
            refresh()
            stateChanged("Expansion", { All = true, Expanded = false })
            return true
        end
        function c:SetQuery(query)
            self.Query = string.lower(tostring(query or ""))
            scroll.CanvasPosition = Vector2.zero
            refresh()
            self:_dataEvent("Filter", self.Query)
            return true
        end
        function c:Select(id, silent)
            id = id == nil and nil or tostring(id)
            if id and (not byId[id] or byId[id].Disabled) then return false end
            if not self:IsAvailable() then return false end
            self.SelectedId = id
            render()
            stateChanged("Selection", id, silent)
            if not silent then
                self:_emit(id, id and {
                    Id = byId[id].Id, Label = byId[id].Label,
                    Detail = byId[id].Detail, Badge = byId[id].Badge,
                } or nil)
            end
            return true
        end
        function c:Update(id, change)
            id = tostring(id)
            local node = byId[id]
            if not node or type(change) ~= "table" then return false end
            -- Structural changes use SetNodes to ensure index integrity.
            if change.Id ~= nil or change.Key ~= nil or change.Children ~= nil then return false end
            if change.Label ~= nil then node.Label = tostring(change.Label) end
            if change.Detail ~= nil then node.Detail = tostring(change.Detail) end
            if change.Badge ~= nil then node.Badge = tostring(change.Badge) end
            if change.Disabled ~= nil then node.Disabled = change.Disabled == true end
            if self.SelectedId == id and node.Disabled then self.SelectedId = nil end
            refresh()
            self:_dataEvent("Data", { Operation = "Update", Id = id })
            return true
        end
        function c:Remove(id)
            id = tostring(id)
            if not byId[id] then return false end
            local function prune(nodes)
                for i = #nodes, 1, -1 do
                    if nodes[i].Id == id then table.remove(nodes, i); return true end
                    if prune(nodes[i].Children) then return true end
                end
                return false
            end
            local remainder = treeSnapshot(roots)
            prune(remainder)
            return self:SetNodes(remainder)
        end
        function c:SetLoading(value)
            self.Loading = value == true
            if self.Loading then self.Error = nil end
            render()
        end
        function c:SetError(err)
            self.Loading = false
            self.Error = err == nil and nil or tostring(err)
            render()
        end
        local function dispose()
            if not alive then return end
            -- A parent Section can destroy the row without calling c:Destroy().
            -- Flush any debounced tree preference before disconnecting it,
            -- then remove stale registry and cross-component references.
            flushPersistence()
            alive = false
            c._disposed = true
            for _, conn in connections do conn:Disconnect() end
            table.clear(connections)
            table.clear(slots)
            -- Hub:_teardown() preserves the recipe for Reinitialize().
            -- Removing controls from that live recipe while destroying the
            -- entire hub would erase steps and break forwarded data links.
            if not hub._destroyed then complexForgetControl(c) end
        end
        function c:Destroy()
            if not alive then return end
            dispose()
            row:Destroy()
        end
        connect(scroll:GetPropertyChangedSignal("CanvasPosition"), render)
        connect(scroll:GetPropertyChangedSignal("AbsoluteSize"), render)
        connect(row.Destroying, dispose)
        hub:BindToken(shell, "BackgroundColor3", "Color.Surface1")
    hub:BindToken(shell:FindFirstChildOfClass("UIStroke"), "Color", "Color.BorderSubtle")
        hub:BindToken(shell:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
        c:SetNodes(options.Nodes or options.Items or {})
        if type(savedState) == "table" then c:SetState(savedState, true) end
        restoring = false
        c.Value = stateSnapshot()
        hub._treeControls = hub._treeControls or {}
        table.insert(hub._treeControls, c)
        return hub:_finishRequiredControl(c)
    end
end

-- SPDX-License-Identifier: MPL-2.0
-- Optional native Roblox 3D preview. No RenderStepped loops, no remote assets.
-- Clones source objects; never reparents or destroys caller-owned instances.
function Section:ViewportPreview(options)
    options = type(options) == "table" and options or {}
    local hub, theme = self.Hub, self.Hub.Theme
    local previewHeight = math.clamp(tonumber(options.Height) or 190, 110, 380)
    local row = self:_row(previewHeight + (options.Name and 27 or 0) + 7,
        "ViewportPreview_" .. (options.Name or "Preview"))
    local c = self:_control("ViewportPreview", options, row)
    local alive = true
    c.Interactive = options.Interactive == true
    c.Yaw, c.Pitch = 0, math.rad(-10)
    c.Zoom = 1
    c.Source = options.Object or options.Model
    c.Available = false
    local origin = options.Name and 26 or 0
    if options.Name then
        text({ Name = "Title", Parent = row, Text = c.Name,
            TextSize = 13, FontFace = inter(Enum.FontWeight.SemiBold),
            Size = UDim2.new(1, 0, 0, 20), TextTruncate = Enum.TextTruncate.AtEnd })
    end
    local surface = create("Frame", {
        Name = "ViewportSurface", Parent = row, BackgroundColor3 = themeColor(theme, "Field"),
        Position = UDim2.fromOffset(0, origin),
        Size = UDim2.new(1, 0, 0, previewHeight), ClipsDescendants = true,
    }, { corner(8), stroke(themeColor(theme, "FieldStroke")) })
    local fallback = text({ Name = "ViewportFallback", Parent = surface,
        Text = "3D previews unavailable on this runtime",
        TextSize = 11, TextColor3 = themeColor(theme, "Muted"),
        TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true,
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0) })
    local available, viewport = pcall(function()
        return create("ViewportFrame", {
            Name = "NativeViewport", Parent = surface, BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1), Active = c.Interactive,
            Ambient = Color3.fromRGB(195, 195, 205),
            LightColor = Color3.fromRGB(255, 255, 255),
            LightDirection = Vector3.new(-1, -1, -1),
        })
    end)
    if not available or not viewport then
        c.Error = "ViewportFrame is unsupported"
        function c:SetModel(instance) self.Source = instance; return false, self.Error end
        function c:Get() return self.Source end
        function c:SetInteractive(on) self.Interactive = on == true end
        function c:ResetView() self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1 end
        function c:Destroy()
            if not alive then return end
            alive = false
            complexForgetControl(self)
            row:Destroy()
        end
        return hub:_finishRequiredControl(c)
    end

    local world, camera
    local ok3d, err3d = pcall(function()
        world = Instance.new("WorldModel")
        world.Name = "PreviewWorld"
        world.Parent = viewport
        camera = Instance.new("Camera")
        camera.Name = "PreviewCamera"
        camera.FieldOfView = 45
        camera.Parent = viewport
        viewport.CurrentCamera = camera
    end)
    if not ok3d then
        c.Error = tostring(err3d)
        viewport:Destroy()
        fallback.Visible = true
        function c:SetModel(instance) self.Source = instance; return false, self.Error end
        function c:Get() return self.Source end
        function c:SetInteractive(on) self.Interactive = on == true end
        function c:ResetView() self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1 end
        function c:Destroy()
            if not alive then return end
            alive = false
            complexForgetControl(self)
            row:Destroy()
        end
        return hub:_finishRequiredControl(c)
    end
    c.Available = true
    fallback.Visible = false
    local cloned
    local center = Vector3.zero
    local radius = 6
    local function view()
        if not alive or hub._destroyed or not camera or not camera.Parent then return end
        local distance = radius * math.clamp(c.Zoom, .6, 3.5)
        local cosPitch = math.cos(c.Pitch)
        local offset = Vector3.new(
            math.sin(c.Yaw) * cosPitch * distance,
            math.sin(c.Pitch) * distance,
            math.cos(c.Yaw) * cosPitch * distance)
        camera.CFrame = CFrame.lookAt(center + offset, center)
    end
    function c:SetModel(source)
        if not alive then return false, "destroyed" end
        if source ~= nil and (typeof(source) ~= "Instance"
            or not (source:IsA("Model") or source:IsA("BasePart"))) then
            return false, "ViewportPreview accepts a Model or BasePart"
        end
        local fresh
        if source then
            local success, result = pcall(function() return source:Clone() end)
            if not success or not result then return false, "failed to clone source model" end
            fresh = result
            -- No scripts are needed for static previews. Do not execute cloned code.
            for _, node in fresh:GetDescendants() do
                if node:IsA("LuaSourceContainer") then node:Destroy() end
            end
        end
        if cloned then cloned:Destroy(); cloned = nil end
        self.Source = source
        cloned = fresh
        center, radius = Vector3.zero, 6
        if cloned then
            cloned.Parent = world
            local ok, cf, size = pcall(function()
                if cloned:IsA("Model") then return cloned:GetBoundingBox()
                else return cloned.CFrame, cloned.Size end
            end)
            if ok and cf and size then
                center = cf.Position
                radius = math.max(2.5, size.Magnitude * 1.15)
            end
        end
        self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1
        view()
        return true
    end
    function c:Get() return self.Source end
    function c:SetInteractive(on)
        self.Interactive = on == true
        viewport.Active = self.Interactive
    end
    function c:Rotate(deltaX, deltaY)
        self.Yaw += (tonumber(deltaX) or 0) * .008
        self.Pitch = math.clamp(self.Pitch + (tonumber(deltaY) or 0) * .008,
            math.rad(-75), math.rad(75))
        view()
    end
    function c:SetZoom(value)
        self.Zoom = math.clamp(tonumber(value) or 1, .6, 3.5)
        view()
    end
    function c:ResetView()
        self.Yaw, self.Pitch, self.Zoom = 0, math.rad(-10), 1
        view()
    end
    function c:Destroy()
        if not alive then return end
        alive = false
        if self._previewDrag then self._previewDrag:Disconnect(); self._previewDrag = nil end
        if cloned then cloned:Destroy(); cloned = nil end
        if camera then camera:Destroy(); camera = nil end
        if world then world:Destroy(); world = nil end
        complexForgetControl(self)
        row:Destroy()
    end
    local lastPosition
    c._previewDrag = bindPointerDrag(hub, viewport, {
        Start = function(input)
            if not c.Interactive or not c:IsAvailable() then error("preview is not interactive") end
            lastPosition = Vector2.new(input.Position.X, input.Position.Y)
        end,
        Move = function(input)
            if not lastPosition then return end
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            c:Rotate(pos.X - lastPosition.X, pos.Y - lastPosition.Y)
            lastPosition = pos
        end,
        End = function() lastPosition = nil end,
    }, true)
    hub:_connect(viewport.InputChanged, function(input)
        if c.Interactive and input.UserInputType == Enum.UserInputType.MouseWheel then
            c:SetZoom(c.Zoom * (input.Position.Z > 0 and .9 or 1.1))
        end
    end)
    local zoomOut = create("TextButton", {
        Name = "ZoomOut", Text = "−", Parent = surface,
        Position = UDim2.new(1, -72, 1, -30), Size = UDim2.fromOffset(29, 25),
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .12, TextColor3 = themeColor(theme, "Text"),
        TextSize = 16, AutoButtonColor = false, Visible = c.Interactive, ZIndex = 6,
    }, { corner(6) })
    local zoomIn = create("TextButton", {
        Name = "ZoomIn", Text = "+", Parent = surface,
        Position = UDim2.new(1, -37, 1, -30), Size = UDim2.fromOffset(29, 25),
        BackgroundColor3 = themeColor(theme, "Tile"),
        BackgroundTransparency = .12, TextColor3 = themeColor(theme, "Text"),
        TextSize = 16, AutoButtonColor = false, Visible = c.Interactive, ZIndex = 6,
    }, { corner(6) })
    hub:_connect(zoomOut.MouseButton1Click, function() c:SetZoom(c.Zoom * 1.2) end)
    hub:_connect(zoomIn.MouseButton1Click, function() c:SetZoom(c.Zoom / 1.2) end)
    hub:_connect(row.Destroying, function()
        if alive then
            alive = false
            if c._previewDrag then c._previewDrag:Disconnect(); c._previewDrag = nil end
        end
    end)
    local setInteractive = c.SetInteractive
    function c:SetInteractive(on)
        setInteractive(self, on)
        zoomOut.Visible, zoomIn.Visible = self.Interactive, self.Interactive
    end
    if c.Source then
        local success, why = c:SetModel(c.Source)
        if not success then c.Error = why end
    else view() end
    return hub:_finishRequiredControl(c)
end


---------------------------------------------------------------- RangeSlider
function Section:RangeSlider(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local min, max = options.Min or 0, options.Max or 100
	local step = options.Step or 1
	local suffix = options.Suffix or ""
	local row = self:_row(46, "Range_" .. (options.Name or ""))
	local c = self:_control("RangeSlider", options, row)
	c.Min, c.Max, c.Step = min, max, step
	local d = options.Default or { min, max }
	local function clean(lo, hi)
		lo = math.clamp(round(tonumber(lo) or min, step, min), min, max)
		hi = math.clamp(round(tonumber(hi) or max, step, min), min, max)
		if lo > hi then lo, hi = hi, lo end
		return lo, hi
	end
	local lo0, hi0 = clean(d[1] or d.Min, d[2] or d.Max)
	c.Value = { Min = lo0, Max = hi0 }
	text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 7), Size = UDim2.new(1, -110, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	local readout = text({ Parent = row, Name = "Value", Text = "", FontFace = MONO, TextSize = 12, TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 7), Size = UDim2.fromOffset(110, 16) })
	local track = create("Frame", { Name = "Track", BackgroundColor3 = themeColor(theme, "Track"), BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 2), Parent = row }, { corner(1) })
	local fill = create("Frame", { Name = "Fill", BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = track }, { corner(1) })
	local function notch(name)
		local k = create("Frame", { Name = name, BackgroundColor3 = themeColor(theme, "Accent"), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(4, 14), ZIndex = 2, Parent = track }, { corner(2) })
		return k, create("UIScale", { Parent = k })
	end
	local lowKnob, lowGrow = notch("Low")
	local highKnob, highGrow = notch("High")
	local hit = create("TextButton", { Name = "Hit", BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(-6, 24), Size = UDim2.new(1, 12, 0, 22), ZIndex = 3, Parent = row })
	local function frac(v) return (max > min) and (v - min) / (max - min) or 0 end
	local function render()
		local a, b = frac(c.Value.Min), frac(c.Value.Max)
		fill.Position = UDim2.fromScale(a, 0)
		fill.Size = UDim2.fromScale(b - a, 1)
		lowKnob.Position = UDim2.fromScale(a, 0.5)
		highKnob.Position = UDim2.fromScale(b, 0.5)
		readout.Text = formatNumber(c.Value.Min, step) .. " – " .. formatNumber(c.Value.Max, step) .. suffix
	end
	function c:Set(value, silent: boolean?)
		local lo, hi
		if type(value) == "table" then
			lo, hi = clean(value[1] or value.Min, value[2] or value.Max)
		else
			lo, hi = self.Value.Min, self.Value.Max
		end
		if lo == self.Value.Min and hi == self.Value.Max then render() return end
		self.Value = { Min = lo, Max = hi }
		render()
		if not silent then self:_emit(lo, hi) end
	end
	function c:Get() return self.Value.Min, self.Value.Max end
	render()
	local dragging
	local function valueAt(x)
		local p, s = track.AbsolutePosition, track.AbsoluteSize
		if s.X <= 0 then return nil end
		return min + (max - min) * math.clamp((x - p.X) / s.X, 0, 1)
	end
	local function move(x)
		local v = valueAt(x)
		if not v then return end
		v = math.clamp(round(v, step, min), min, max)
		-- a knob can't pass the other one; it stops against it
		if dragging == "Min" then
			c:Set({ math.min(v, c.Value.Max), c.Value.Max })
		else
			c:Set({ c.Value.Min, math.max(v, c.Value.Min) })
		end
	end
	bindPointerDrag(hub, hit, {
		Start = function(input)
			local v = valueAt(input.Position.X)
			if not v then return end
			local dLo, dHi = math.abs(v - c.Value.Min), math.abs(v - c.Value.Max)
			dragging = (dLo < dHi or (dLo == dHi and v < c.Value.Min)) and "Min" or "Max"
			tween(dragging == "Min" and lowGrow or highGrow, SETTLE, { Scale = 1.25 })
			move(input.Position.X)
		end,
		Move = function(input) if dragging then move(input.Position.X) end end,
		End = function()
			if dragging then tween(dragging == "Min" and lowGrow or highGrow, SETTLE, { Scale = 1 }) end
			dragging = nil
		end,
	})
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Progress / meter
function Section:Progress(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local min, max = options.Min or 0, options.Max or 100
	local segments = options.Segments
	local row = self:_row(options.Name and 42 or 22, "Progress_" .. (options.Name or ""))
	local c = self:_control("Progress", options, row)
	c.Value = math.clamp(options.Default or options.Value or min, min, max)
	local top = 0
	local readout
	if options.Name then
		top = 26
		text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 5), Size = UDim2.new(1, -90, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		readout = text({ Parent = row, Name = "Value", Text = "", FontFace = MONO, TextSize = 12, TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 5), Size = UDim2.fromOffset(90, 16) })
	end
	local bar = create("Frame", { Name = "Bar", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, top + 4), Size = UDim2.new(1, 0, 0, 6), Parent = row })
	local color = options.Color
	local fills = {}
	if segments and segments > 1 then
		create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = bar })
		for i = 1, segments do
			local seg = create("Frame", { Name = "Segment", BackgroundColor3 = themeColor(theme, "Track"), BorderSizePixel = 0, Size = UDim2.new(1 / segments, -3 + 3 / segments, 1, 0), LayoutOrder = i, Parent = bar }, { corner(2) })
			table.insert(fills, create("Frame", { Name = "Fill", BackgroundColor3 = color or themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = seg }, { corner(2) }))
		end
	else
		local back = create("Frame", { Name = "Track", BackgroundColor3 = themeColor(theme, "Track"), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = bar }, { corner(3) })
		table.insert(fills, create("Frame", { Name = "Fill", BackgroundColor3 = color or themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), Parent = back }, { corner(3) }))
	end
	local format = options.Format
	local function render(animate)
		local a = (max > min) and (c.Value - min) / (max - min) or 0
		local n = #fills
		for i, f in fills do
			-- each segment fills its own share of the bar
			local share = math.clamp(a * n - (i - 1), 0, 1)
			local goal = { Size = UDim2.fromScale(share, 1) }
			if animate then tween(f, SOFT, goal) else f.Size = goal.Size end
		end
		if readout then
			readout.Text = format and format(c.Value, min, max) or (math.floor(a * 100 + 0.5) .. "%")
		end
	end
	function c:Set(value: number)
		value = math.clamp(tonumber(value) or min, min, max)
		if value == self.Value then return end
		self.Value = value
		render(true)
	end
	c.Update = c.Set
	function c:SetColor(col: Color3)
		for _, f in fills do setThemed(f, "BackgroundColor3", col) end
	end
	function c:Get() return self.Value end
	render(false)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Stat
function Section:Stat(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local row = self:_row(30, "Stat_" .. (options.Name or ""))
	local c = self:_control("Stat", options, row)
	c.Value = options.Default or options.Value
	local format = options.Format
	local deltas = options.Delta
	text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Size = UDim2.new(0.5, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
	local holder = create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.5, 0, 1, 0), Parent = row }, {
		list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
	})
	local delta = text({ Parent = holder, Name = "Delta", Text = "", FontFace = MONO, TextSize = 11, Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, TextTransparency = 1, LayoutOrder = 1 })
	local value = text({ Parent = holder, Name = "Value", Text = "", FontFace = MONO, TextSize = 12, TextColor3 = themeColor(theme, "Text"), Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2 })
	local function show(v)
		if format then return format(v) end
		if type(v) == "number" then
			local s = (v == math.floor(v)) and string.format("%d", v) or string.format("%.2f", v)
			-- group thousands so long numbers stay readable
			local int, rest = string.match(s, "^(-?%d+)(.*)$")
			if int and #string.gsub(int, "^-", "") >= 4 then
				int = string.reverse((string.gsub(string.reverse(int), "(%d%d%d)", "%1,")))
				int = string.gsub(int, "^(-?),", "%1")
			end
			return (int or s) .. (rest or "") .. (options.Suffix or "")
		end
		return tostring(v == nil and "—" or v) .. (options.Suffix or "")
	end
	local fadeToken = 0
	function c:Update(v)
		local old = self.Value
		self.Value = v
		local s = show(v)
		-- only touch the label when the text changes, so it never flickers
		if value.Text ~= s then value.Text = s end
		if deltas and type(v) == "number" and type(old) == "number" and v ~= old then
			local up = v > old
			local good = (options.HigherIsBetter == false) ~= up
			local col = themeColor(theme, good and "Success" or "Danger")
			setThemed(delta, "TextColor3", col)
			setThemed(value, "TextColor3", col)
			delta.Text = (up and "+" or "") .. show(v - old)
			delta.TextTransparency = 0
			fadeToken += 1
			local token = fadeToken
			task.delay(1.4, function()
				if token ~= fadeToken then return end
				tween(delta, SOFT, { TextTransparency = 1 })
				tween(value, SOFT, { TextColor3 = themeColor(theme, "Text") })
			end)
		end
	end
	c.Set = c.Update
	function c:Get() return self.Value end
	value.Text = show(c.Value)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Sparkline
function Section:Sparkline(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local count = math.clamp(options.Points or 40, 4, 120)
	local row = self:_row(64, "Spark_" .. (options.Name or ""))
	local c = self:_control("Sparkline", options, row)
	c.Values = {}
	text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, -90, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
	local readout = text({ Parent = row, Name = "Value", Text = "—", FontFace = MONO, TextSize = 12, TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 4), Size = UDim2.fromOffset(90, 16) })
	local plot = create("Frame", { Name = "Plot", BackgroundColor3 = themeColor(theme, "Field"), Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 34), ClipsDescendants = true, Parent = row }, { corner(6), stroke(themeColor(theme, "FieldStroke")) })
	local area = create("Frame", { Name = "Area", BackgroundTransparency = 1, Position = UDim2.fromOffset(4, 5), Size = UDim2.new(1, -8, 1, -10), Parent = plot })
	local color = options.Color
	local segs = {}
	for i = 1, count - 1 do
		segs[i] = create("Frame", { Name = "Seg", BackgroundColor3 = color or themeColor(theme, "Accent"), BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 1.5), Visible = false, Parent = area })
	end
	local dot = create("Frame", { Name = "Head", BackgroundColor3 = color or themeColor(theme, "Accent"), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(4, 4), Visible = false, ZIndex = 2, Parent = area }, { corner(2) })
	local function draw()
		local vals = c.Values
		local n = #vals
		local w, h = area.AbsoluteSize.X / hub._scale, area.AbsoluteSize.Y / hub._scale
		if n < 2 or w <= 0 then
			for _, s in segs do s.Visible = false end
			dot.Visible = false
			return
		end
		local lo, hi = options.Min, options.Max
		if lo == nil or hi == nil then
			local a, b = math.huge, -math.huge
			for _, v in vals do a = math.min(a, v) b = math.max(b, v) end
			if a == b then a, b = a - 1, b + 1 end
			lo, hi = lo or a, hi or b
		end
		local dx = w / (count - 1)
		-- newest point sits on the right edge; older ones scroll left
		local x0 = w - (n - 1) * dx
		local function pt(i)
			local t = math.clamp((vals[i] - lo) / (hi - lo), 0, 1)
			return x0 + (i - 1) * dx, h - t * h
		end
		for i, s in segs do
			if i < n then
				local ax, ay = pt(i)
				local bx, by = pt(i + 1)
				local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
				s.Position = UDim2.fromOffset((ax + bx) / 2, (ay + by) / 2)
				s.Size = UDim2.fromOffset(len + 0.6, 1.5)
				s.Rotation = math.deg(math.atan2(by - ay, bx - ax))
				s.Visible = true
			else
				s.Visible = false
			end
		end
		local hx, hy = pt(n)
		dot.Position = UDim2.fromOffset(hx, hy)
		dot.Visible = true
	end
	function c:Push(v: number)
		v = tonumber(v)
		if not v then return end
		table.insert(self.Values, v)
		while #self.Values > count do table.remove(self.Values, 1) end
		local s = options.Format and options.Format(v) or (formatNumber(v, options.Step or 1) .. (options.Suffix or ""))
		if readout.Text ~= s then readout.Text = s end
		draw()
	end
	c.Update = c.Push
	function c:Clear()
		table.clear(self.Values)
		readout.Text = "—"
		draw()
	end
	function c:Get() return self.Values[#self.Values] end
	hub:_connect(area:GetPropertyChangedSignal("AbsoluteSize"), draw)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Segmented
function Section:Segmented(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local opts = options.Options or {}
	local row = self:_row(options.Name and 58 or 34, "Segmented_" .. (options.Name or ""))
	local c = self:_control("Segmented", options, row)
	c.Options = table.clone(opts)
	c.Value = options.Default or opts[1]
	local top = 0
	if options.Name then
		text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 6), Size = UDim2.new(1, 0, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
		top = 26
	end
	local track = create("Frame", { Name = "Track", BackgroundColor3 = themeColor(theme, "Field"), Position = UDim2.fromOffset(0, top + 2), Size = UDim2.new(1, 0, 0, 28), Parent = row }, { corner(7), stroke(themeColor(theme, "FieldStroke")) })
	local n = math.max(1, #opts)
	local pill = create("Frame", { Name = "Pill", BackgroundColor3 = themeColor(theme, "TileActive"), Position = UDim2.new(0, 2, 0, 2), Size = UDim2.new(1 / n, -4, 1, -4), Parent = track }, { corner(5), stroke(themeColor(theme, "TileActiveStroke")) })
	local labels = {}
	for i, o in opts do
		local b = create("TextButton", { Name = "Segment", BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Position = UDim2.fromScale((i - 1) / n, 0), Size = UDim2.fromScale(1 / n, 1), ZIndex = 2, Parent = track })
		labels[i] = text({ Parent = b, Text = tostring(o), TextSize = 12, FontFace = inter(Enum.FontWeight.Medium), TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 })
		hub:_connect(b.MouseButton1Click, function() c:Set(o) end)
		hub:_connect(b.MouseEnter, function() if c.Value ~= o then setThemed(labels[i], "TextColor3", themeColor(theme, "Text")) end end)
		hub:_connect(b.MouseLeave, function() if c.Value ~= o then setThemed(labels[i], "TextColor3", themeColor(theme, "SubText")) end end)
	end
	local function render(animate)
		local i = table.find(opts, c.Value) or 1
		local goal = { Position = UDim2.new((i - 1) / n, 2, 0, 2) }
		if animate then tween(pill, SETTLE, goal) else pill.Position = goal.Position end
		for j, l in labels do
			setThemed(l, "TextColor3", themeColor(theme, j == i and "Text" or "SubText"))
		end
	end
	function c:Set(v, silent: boolean?)
		if not table.find(opts, v) or v == self.Value then return end
		self.Value = v
		render(true)
		if not silent then self:_emit(v) end
	end
	function c:Get() return self.Value end
	render(false)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Stepper
function Section:Stepper(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local min, max, step = options.Min or 0, options.Max or 10, options.Step or 1
	local row = self:_row(34, "Stepper_" .. (options.Name or ""))
	local c = self:_control("Stepper", options, row)
	c.Value = math.clamp(round(options.Default or min, step), min, max)
	self:_labels(row, c.Name, options.Description, 96)
	local box = create("Frame", { Name = "Stepper", BackgroundColor3 = themeColor(theme, "Field"), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(92, 24), Parent = row }, { corner(6), stroke(themeColor(theme, "FieldStroke")) })
	local function button(name, icon, x, anchor)
		local b = create("TextButton", { Name = name, BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(anchor, 0), Position = UDim2.fromScale(x, 0), Size = UDim2.new(0, 26, 1, 0), Parent = box }, { corner(6) })
		local ic = iconLabel(icon, 13, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = b })
		if not ic then text({ Parent = b, Text = icon == "minus" and "–" or "+", TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) }) end
		return b, ic
	end
	local minus, minusIcon = button("Decrease", "minus", 0, 0)
	local plus, plusIcon = button("Increase", "plus", 1, 1)
	local value = text({ Parent = box, Name = "Value", Text = "", FontFace = MONO, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -52, 1, 0) })
	local function render()
		value.Text = formatNumber(c.Value, step) .. (options.Suffix or "")
		if minusIcon then setThemed(minusIcon, "ImageColor3", themeColor(theme, c.Value <= min and "Muted" or "SubText")) end
		if plusIcon then setThemed(plusIcon, "ImageColor3", themeColor(theme, c.Value >= max and "Muted" or "SubText")) end
	end
	function c:Set(v, silent: boolean?)
		v = math.clamp(round(tonumber(v) or min, step), min, max)
		if v == self.Value then return end
		self.Value = v
		render()
		if not silent then self:_emit(v) end
	end
	function c:Get() return self.Value end
	render()
	-- Holding a button repeats, faster the longer it's held.
	local function hold(b, dir)
		local token = 0
		hub:_connect(b.MouseEnter, function() tween(b, FAST, { BackgroundTransparency = 0 }) end)
		hub:_connect(b.MouseLeave, function() token += 1 tween(b, FAST, { BackgroundTransparency = 1 }) end)
		hub:_connect(b.MouseButton1Down, function()
			token += 1
			local mine = token
			c:Set(c.Value + dir * step)
			task.delay(0.4, function()
				local wait = 0.12
				while token == mine and not hub._destroyed do
					c:Set(c.Value + dir * step)
					task.wait(wait)
					wait = math.max(0.03, wait * 0.85)
				end
			end)
		end)
		hub:_connect(b.MouseButton1Up, function() token += 1 end)
	end
	hold(minus, -1)
	hold(plus, 1)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- Console
function Section:Console(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local hub, theme = self.Hub, self.Hub.Theme
	local maxLines = options.MaxLines or 200
	local height = options.Height or 150
	local row = self:_row(height + 30, "Console_" .. (options.Name or ""))
	local c = self:_control("Console", options, row)
	c.Lines = {}
	text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, -70, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
	local function tool(name, icon, x)
		local b = create("TextButton", { Name = name, BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 0), Size = UDim2.fromOffset(26, 24), Parent = row }, { corner(6) })
		local ic = iconLabel(icon, 14, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = b })
		hub:_connect(b.MouseEnter, function() tween(b, FAST, { BackgroundTransparency = 0 }) end)
		hub:_connect(b.MouseLeave, function() tween(b, FAST, { BackgroundTransparency = 1 }) end)
		return b, ic
	end
	local copy, copyIcon = tool("CopyLog", "copy", -30)
	local clear = tool("ClearLog", "trash-2", 0)
	local scroll = create("ScrollingFrame", {
		Name = "Log", BackgroundColor3 = themeColor(theme, "Field"), BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, height),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"), ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = row,
	}, { corner(6), stroke(themeColor(theme, "FieldStroke")), padding(6, 8), list(Enum.FillDirection.Vertical, 2) })
	local empty = text({ Parent = scroll, Name = "Empty", Text = options.Placeholder or "Nothing logged yet", FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "Muted"), Size = UDim2.new(1, 0, 0, 14) })
	local labels = {}
	local order = 0
	local KIND = { warn = "Warning", warning = "Warning", error = "Danger", success = "Success", info = "Text" }
	local function stamp() return os.date("%H:%M:%S") end
	function c:Log(message, kind: string?)
		message = tostring(message)
		local h = scroll.AbsoluteSize.Y / hub._scale
		local atBottom = scroll.CanvasPosition.Y + h >= scroll.AbsoluteCanvasSize.Y / hub._scale - 24
		order += 1
		local line = options.Timestamps == false and message or (stamp() .. "  " .. message)
		table.insert(self.Lines, line)
		local label = text({ Parent = scroll, Name = "Line", Text = line, FontFace = MONO, TextSize = 11, TextWrapped = true, TextColor3 = themeColor(theme, KIND[string.lower(kind or "info")] or "Text"), Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order })
		table.insert(labels, label)
		empty.Visible = false
		while #labels > maxLines do
			table.remove(labels, 1):Destroy()
			table.remove(self.Lines, 1)
		end
		-- follow new lines only if the reader was already at the bottom
		if atBottom then
			task.defer(function()
				scroll.CanvasPosition = Vector2.new(0, math.max(0, scroll.AbsoluteCanvasSize.Y / hub._scale - scroll.AbsoluteSize.Y / hub._scale))
			end)
		end
	end
	c.Print = c.Log
	function c:Clear()
		for _, l in labels do l:Destroy() end
		table.clear(labels)
		table.clear(self.Lines)
		empty.Visible = true
	end
	function c:Get() return table.concat(self.Lines, "\n") end
	hub:_connect(clear.MouseButton1Click, function() c:Clear() end)
	hub:_connect(copy.MouseButton1Click, function()
		if typeof(setclipboard) == "function" then
			setclipboard(c:Get())
			if copyIcon then
				setThemed(copyIcon, "ImageColor3", themeColor(theme, "Success"))
				task.delay(0.9, function() setThemed(copyIcon, "ImageColor3", themeColor(theme, "SubText")) end)
			end
		else
			hub:Notify({ Title = "No clipboard", Content = "This executor can't copy text.", Tone = hub.Theme.Warning })
		end
	end)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- List
--[[
	Rows of data the script owns: waypoints, saved positions, logs of players. An item is a
	string or an array of cell strings; Columns adds a header and splits each row into cells.
	Clicking a row selects it (Callback(item, index)); Removable adds a remove button that
	calls OnRemove(item, index) and drops the row. Items are data, not settings, so lists
	are left out of configs.
]]
function Section:List(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local hub, theme = self.Hub, self.Hub.Theme
	local columns = type(options.Columns) == "table" and #options.Columns > 0 and options.Columns or nil
	local ncols = columns and #columns or 1
	local widths = {}
	do
		local given, total = options.Widths, 0
		for i = 1, ncols do
			widths[i] = type(given) == "table" and tonumber(given[i]) or 1
			total += widths[i]
		end
		for i = 1, ncols do widths[i] /= total end
	end
	local removable = options.Removable == true or options.OnRemove ~= nil
	local selectable = options.Selectable ~= false
	local height = math.max(60, options.Height or 156)
	local headH = columns and 24 or 0
	local top = options.Name and 26 or 0
	local row = self:_row(top + headH + height + 4, "List_" .. (options.Name or ""))
	local c = self:_control("List", options, row)
	c.Items = {}
	c.Selected = nil
	local count
	if options.Name then
		text({ Parent = row, Name = "Title", Text = c.Name, TextSize = 13, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, -80, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
		count = text({ Parent = row, Name = "Count", Text = "", FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 4), Size = UDim2.fromOffset(80, 18) })
	end
	local frame = create("Frame", {
		Name = "Box", BackgroundColor3 = themeColor(theme, "Field"), Position = UDim2.fromOffset(0, top),
		Size = UDim2.new(1, 0, 0, headH + height), ClipsDescendants = true, Parent = row,
	}, { corner(6), stroke(themeColor(theme, "FieldStroke")) })
	local rightPad = removable and 30 or 0
	local function cells(parent, values, header: boolean, selected: boolean)
		local x = 0
		for i = 1, ncols do
			local w = widths[i]
			text({
				Parent = parent, Name = header and "Column" or "Cell", Text = values[i] or "",
				FontFace = header and inter(Enum.FontWeight.Medium) or ((i > 1 and options.Monospace ~= false) and MONO or inter()),
				TextSize = header and 11 or 12,
				TextColor3 = themeColor(theme, header and "Muted" or ((i == 1 or selected) and "Text" or "SubText")),
				Position = UDim2.new(x, i == 1 and 0 or 8, 0, 0),
				Size = UDim2.new(w, (i == 1 and 0 or -8) - (i == ncols and rightPad or 0), 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			x += w
		end
	end
	if columns then
		local head = create("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, headH), Parent = frame }, { padding(0, 10) })
		local names = {}
		for i, col in columns do names[i] = hub:T(tostring(col)) end
		cells(head, names, true, false)
		create("Frame", { Name = "Divider", BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.fromOffset(0, headH - 1), Size = UDim2.new(1, 0, 0, 1), Parent = frame })
	end
	local scroll = create("ScrollingFrame", {
		Name = "Rows", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, headH), Size = UDim2.new(1, 0, 0, height),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"), ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = frame,
	}, { padding(4, 4), list(Enum.FillDirection.Vertical, 1) })
	local empty = text({ Parent = frame, Name = "Empty", Text = options.Placeholder or "Nothing here yet", TextSize = 12, TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, headH), Size = UDim2.new(1, 0, 0, height) })
	local rows = {}
	local function normalize(item)
		if type(item) ~= "table" then item = { item } end
		local out = {}
		for i = 1, ncols do out[i] = item[i] ~= nil and tostring(item[i]) or "" end
		return out
	end
	local function public(item)
		return ncols == 1 and item[1] or table.clone(item)
	end
	local function paint(i)
		local r = rows[i]
		if not r then return end
		local on = c.Selected == i
		local goal = { BackgroundTransparency = (on or r.Hover) and 0 or 1 }
		setThemed(r.Button, "BackgroundColor3", themeColor(theme, on and "TileActive" or "TileHover"))
		tween(r.Button, FAST, goal)
	end
	-- rows are rebuilt on every change; their connections die with the buttons
	local function render()
		for _, r in rows do r.Button:Destroy() end
		table.clear(rows)
		for i, item in c.Items do
			local b = create("TextButton", {
				Name = "Item", BackgroundColor3 = themeColor(theme, "TileHover"), BackgroundTransparency = 1,
				Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i, Parent = scroll,
			}, { corner(5), padding(0, 6, 0, 6) })
			local r = { Button = b, Hover = false }
			rows[i] = r
			cells(b, item, false, c.Selected == i)
			if removable then
				local x = create("TextButton", {
					Name = "Remove", BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
					AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 2, 0.5, 0), Size = UDim2.fromOffset(22, 22), ZIndex = 2, Parent = b,
				}, { corner(5) })
				local ic = iconLabel("x", 13, theme.Muted, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 3, Parent = x })
				if not ic then text({ Parent = x, Text = "×", TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 }) end
				x.MouseEnter:Connect(function()
					if ic then setThemed(ic, "ImageColor3", themeColor(theme, "Danger")) end
				end)
				x.MouseLeave:Connect(function()
					if ic then setThemed(ic, "ImageColor3", themeColor(theme, "Muted")) end
				end)
				x.MouseButton1Click:Connect(function()
					local index = table.find(c.Items, item)
					if not index or not c:IsAvailable() then return end
					c:Remove(index)
					if options.OnRemove then
						task.spawn(function()
							local ok, err = pcall(options.OnRemove, public(item), index)
							if not ok then recordError(tostring(err), nil, c.Name) warn("[RiftUI] " .. c.Name .. " OnRemove error: " .. tostring(err)) end
						end)
					end
				end)
			end
			b.MouseEnter:Connect(function() r.Hover = true paint(i) end)
			b.MouseLeave:Connect(function() r.Hover = false paint(i) end)
			if selectable then
				b.MouseButton1Click:Connect(function() c:Select(i) end)
			end
			paint(i)
		end
		empty.Visible = #c.Items == 0
		if count then
			local n = #c.Items
			count.Text = n == 0 and "" or (n .. (n == 1 and " item" or " items"))
		end
	end
	function c:Select(index: number?, silent: boolean?)
		if index ~= nil and not self.Items[index] then return end
		self.Selected = index
		render()
		if not silent and index then self:_emit(public(self.Items[index]), index) end
	end
	function c:Add(item, index: number?)
		local entry = normalize(item)
		index = index and math.clamp(math.floor(index), 1, #self.Items + 1) or (#self.Items + 1)
		table.insert(self.Items, index, entry)
		if self.Selected and self.Selected >= index then self.Selected += 1 end
		local max = options.MaxItems
		while type(max) == "number" and #self.Items > max do
			table.remove(self.Items, 1)
			if self.Selected then self.Selected = self.Selected > 1 and self.Selected - 1 or nil end
			index -= 1
		end
		render()
		return math.max(index, 1)
	end
	function c:Remove(index: number)
		if not self.Items[index] then return nil end
		local item = table.remove(self.Items, index)
		if self.Selected == index then
			self.Selected = nil
		elseif self.Selected and self.Selected > index then
			self.Selected -= 1
		end
		render()
		return item
	end
	function c:Update(index: number, item)
		if not self.Items[index] then return end
		self.Items[index] = normalize(item)
		render()
	end
	function c:Set(items)
		table.clear(self.Items)
		for _, item in type(items) == "table" and items or {} do table.insert(self.Items, normalize(item)) end
		self.Selected = nil
		render()
	end
	function c:Clear() self:Set({}) end
	function c:Get()
		local out = {}
		for i, item in self.Items do out[i] = public(item) end
		return out
	end
	function c:GetSelected()
		local item = self.Selected and self.Items[self.Selected]
		if not item then return nil, nil end
		return public(item), self.Selected
	end
	c:Set(options.Items)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- PlayerPicker
local function initials(name: string): string
	local a, b = string.match(name, "^%W*(%w)%w*%W+(%w)")
	return string.upper(a and (a .. b) or string.sub(string.gsub(name, "%W", ""), 1, 2))
end

local function cachedHeadshot(player)
	if not hasAssets then return nil end
	local id = tonumber(player.UserId)
	if not id or id < 1 or id % 1 ~= 0 then return nil end
	local folder = RiftUI.AssetCacheFolder or (RiftUI.Folder .. "/assets")
	local path = folder .. "/avatar-" .. tostring(id) .. ".png"
	local ok, result = pcall(function()
		if not isfile(path) then
			local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(id) .. "&size=150x150&format=Png&isCircular=false"
			local response = HttpService:JSONDecode(game:HttpGet(url))
			local item = response.data and response.data[1]
			assert(item and item.state == "Completed" and type(item.imageUrl) == "string" and string.match(item.imageUrl, "^https://"), "thumbnail unavailable")
			local bytes = game:HttpGet(item.imageUrl)
			assert(type(bytes) == "string" and #bytes <= 1024 * 1024 and string.sub(bytes, 1, 8) == "\137PNG\r\n\26\n", "invalid thumbnail")
			ensureFolder(RiftUI.Folder) ensureFolder(RiftUI.Folder .. "/assets") ensureFolder(folder)
			writefile(path, bytes)
		end
		return getcustomasset(path)
	end)
	if ok and type(result) == "string" then localAssetIds[result] = true return result end
	return nil
end

local function avatar(player, size: number, theme, props)
	local face = create("Frame", { Name = "Avatar", BackgroundColor3 = themeColor(theme, "TileActive"), Size = UDim2.fromOffset(size, size) }, { corner(size / 2) })
	-- initials sit underneath, so a thumbnail that never loads still leaves a face
	text({ Parent = face, Name = "Initials", Text = player and initials(player.DisplayName) or "?", TextSize = math.floor(size * 0.4), FontFace = inter(Enum.FontWeight.SemiBold), TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1) })
	if player then
		local img = create("ImageLabel", { Name = "Thumb", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = face }, { corner(size / 2) })
		task.spawn(function()
			local ok, url = pcall(function()
				if secureAssets() then return cachedHeadshot(player) end
				return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok and url and img.Parent then img.Image = secureProperty("Image", url) end
		end)
	end
	for k, v in props or {} do face[k] = v end
	return face
end

function Section:PlayerPicker(options)
	local hub, theme = self.Hub, self.Hub.Theme
	local row = self:_row(34, "PlayerPicker_" .. (options.Name or ""))
	local c = self:_control("PlayerPicker", options, row)
	c.Value = nil
	local includeSelf = options.IncludeSelf == true
	self:_labels(row, c.Name, options.Description, 150)
	local chip = create("TextButton", {
		Name = "Chip", BackgroundColor3 = themeColor(theme, "Field"), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, Text = "", AutoButtonColor = false, Parent = row,
	}, { corner(6), stroke(themeColor(theme, "FieldStroke")), padding(0, 6, 0, 4), list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center), create("UISizeConstraint", { MaxSize = Vector2.new(150, 26) }) })
	local face
	local label = text({ Parent = chip, Name = "Value", TextSize = 12, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 2 })
	create("UISizeConstraint", { MaxSize = Vector2.new(96, 26), Parent = label })
	iconLabel("chevron-down", 14, theme.SubText, { LayoutOrder = 3, Parent = chip })
	local function players()
		local out = {}
		for _, p in Players:GetPlayers() do
			if includeSelf or p ~= Players.LocalPlayer then table.insert(out, p) end
		end
		table.sort(out, function(a, b) return string.lower(a.DisplayName) < string.lower(b.DisplayName) end)
		return out
	end
	local left = false
	local function render()
		if face then face:Destroy() end
		face = avatar(c.Value, 18, theme, { LayoutOrder = 1, Parent = chip })
		label.Text = c.Value and c.Value.DisplayName or (left and "Left the game" or "None")
		setThemed(label, "TextColor3", themeColor(theme, c.Value and "Text" or "SubText"))
	end
	function c:Set(player, silent: boolean?)
		if type(player) == "string" then
			local name = player
			player = nil
			for _, p in Players:GetPlayers() do
				if p.Name == name or p.DisplayName == name then player = p break end
			end
		end
		if typeof(player) ~= "Instance" then player = nil end
		left = false
		if player == self.Value then render() return end
		self.Value = player
		render()
		if not silent then self:_emit(player) end
	end
	function c:Get() return self.Value end
	if options.Default then c:Set(options.Default, true) else render() end

	local refreshList
	hub:_connect(Players.PlayerAdded, function()
		if refreshList then refreshList() end
	end)
	hub:_connect(Players.PlayerRemoving, function(p)
		if p == c.Value then
			c.Value = nil
			left = true
			render()
			c:_emit(nil)
		end
		task.defer(function() if refreshList then refreshList() end end)
	end)
	hub:_connect(chip.MouseButton1Click, function()
		if hub._popup and hub._popup.Anchor == chip then hub:_closePopup() return end
		local itemH = 40
		local frame = create("Frame", { Name = "PlayerList", BackgroundColor3 = themeColor(theme, "Panel"), Size = UDim2.fromOffset(240, 8), ZIndex = 41 }, { corner(10), stroke(themeColor(theme, "PanelStroke")), padding(4) })
		local search = create("TextBox", {
			Name = "Filter", BackgroundColor3 = themeColor(theme, "Field"), Size = UDim2.new(1, 0, 0, 28),
			PlaceholderText = "Search players", PlaceholderColor3 = themeColor(theme, "Muted"), Text = "", FontFace = inter(), TextSize = 12,
			TextColor3 = themeColor(theme, "Text"), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 42, Parent = frame,
		}, { corner(6), padding(0, 8) })
		local scroll = create("ScrollingFrame", {
			Name = "Items", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, 0, 1, -32),
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = themeColor(theme, "Knob"), ZIndex = 42, Parent = frame,
		}, { list(Enum.FillDirection.Vertical, 0) })
		local count = create("TextLabel", { Name = "Count", BackgroundTransparency = 1, Text = "", FontFace = MONO, TextSize = 10, TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(40, 28), ZIndex = 43, Parent = frame })
		local function build()
			for _, ch in scroll:GetChildren() do if ch:IsA("GuiObject") then ch:Destroy() end end
			local q = string.lower(search.Text)
			local all = players()
			local shown = 0
			for i, p in all do
				if q == "" or string.find(string.lower(p.DisplayName), q, 1, true) or string.find(string.lower(p.Name), q, 1, true) then
					shown += 1
					local on = p == c.Value
					local item = create("TextButton", { Name = "Player_" .. p.Name, BackgroundColor3 = themeColor(theme, "Tile"), BackgroundTransparency = on and 0 or 1, Size = UDim2.new(1, 0, 0, itemH), Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 43, Parent = scroll }, { corner(6) })
					avatar(p, 26, theme, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), ZIndex = 44, Parent = item })
					text({ Parent = item, Text = p.DisplayName, TextSize = 13, FontFace = inter(Enum.FontWeight.Medium), Position = UDim2.fromOffset(42, 4), Size = UDim2.new(1, -66, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 44 })
					text({ Parent = item, Text = "@" .. p.Name, TextSize = 11, TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(42, 20), Size = UDim2.new(1, -66, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 44 })
					iconLabel("check", 14, theme.Text, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Visible = on, ZIndex = 44, Parent = item })
					item.MouseEnter:Connect(function() tween(item, FAST, { BackgroundTransparency = 0 }) end)
					item.MouseLeave:Connect(function() tween(item, FAST, { BackgroundTransparency = p == c.Value and 0 or 1 }) end)
					item.MouseButton1Click:Connect(function()
						c:Set(p)
						hub:_closePopup()
					end)
				end
			end
			if shown == 0 then
				text({ Parent = scroll, Text = #all == 0 and "Nobody else is here" or "No match", TextColor3 = themeColor(theme, "Muted"), Size = UDim2.new(1, 0, 0, itemH), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 43 })
			end
			count.Text = tostring(#all)
			frame.Size = UDim2.fromOffset(240, 8 + 32 + math.max(1, math.min(shown, 6)) * itemH)
			if frame.Parent then frame.Parent.Size = frame.Size end
		end
		build()
		search:GetPropertyChangedSignal("Text"):Connect(build)
		refreshList = build
		hub:_openPopup(chip, frame, function() refreshList = nil end)
	end)
	return self.Hub:_finishRequiredControl(c)
end

---------------------------------------------------------------- pinning
function Section:Pin(position: Vector2?)
	if self.Pinned then
		return
	end
	local hub, theme = self.Hub, self.Hub.Theme
	self.Pinned = true
	self.Frame.Visible = false
	local card = create("Frame", {
		Name = "Pin_" .. self.Name,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(220, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = hub.PinLayer,
	})
	shadow(card, 18, 0, 5)
	local body = create("Frame", {
		Name = "Card",
		BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2,
		Parent = card,
	}, { corner(12), stroke(themeColor(theme, "PanelStroke")), padding(36, 12, 4, 12) })
	local head = create("TextButton", {
		Name = "Drag",
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.fromOffset(-12, -36),
		Size = UDim2.new(1, 24, 0, 34),
		ZIndex = 3,
		Parent = body,
	}, { padding(0, 8, 0, 12) })
	text({ Parent = head, Text = self.Name, FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 13, Size = UDim2.new(1, -28, 1, 0), ZIndex = 4, TextTruncate = Enum.TextTruncate.AtEnd })
	local unpin = create("TextButton", {
		Name = "Unpin",
		BackgroundColor3 = themeColor(theme, "Tile"),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(24, 24),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
		Parent = head,
	}, { corner(6) })
	if not iconLabel("pin-off", 13, theme.Text, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5, Parent = unpin }) then
		text({ Parent = unpin, Text = "x", Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5 })
	end
	self.Rows.Parent = body
	self.Card = card

	local start = position or hub.Pins[self.Id]
	if not start then
		local n = 0
		for _ in hub.Pins do
			n += 1
		end
		start = Vector2.new(16, topInset() + 8 + n * 150)
	end
	card.Position = UDim2.fromOffset(start.X, start.Y + 8)
	tween(card, SETTLE, { Position = UDim2.fromOffset(start.X, start.Y) })
	hub.Pins[self.Id] = start

	local origin, from
	self._pinConns = {
		bindPointerDrag(hub, head, {
			Start = function(input)
				origin = Vector2.new(input.Position.X, input.Position.Y)
				from = Vector2.new(card.Position.X.Offset, card.Position.Y.Offset)
			end,
			Move = function(input)
				local scale = hub._scale
				local delta = (Vector2.new(input.Position.X, input.Position.Y) - origin) / scale
				local vp = viewport() / scale
				local x = math.clamp(from.X + delta.X, 0, math.max(0, vp.X - card.AbsoluteSize.X / scale))
				local y = math.clamp(from.Y + delta.Y, 0, math.max(0, vp.Y - card.AbsoluteSize.Y / scale))
				card.Position = UDim2.fromOffset(x, y)
				hub.Pins[self.Id] = Vector2.new(x, y)
			end,
		}, true),
		unpin.MouseButton1Click:Connect(function() self:Unpin() end),
	}

	if hub._open == self.Tab then
		task.defer(function()
			hub:_fitPanel(self.Tab, true)
		end)
	end
end

function Section:Unpin()
	if not self.Pinned then
		return
	end
	local hub = self.Hub
	self.Pinned = false
	hub.Pins[self.Id] = nil
	for _, c in self._pinConns or {} do
		c:Disconnect()
	end
	self.Rows.Parent = self._rowsClip or self.Frame
	self.Frame.Visible = true
	if self.Card then
		self.Card:Destroy()
		self.Card = nil
	end
	if hub._open == self.Tab then
		task.defer(function()
			hub:_fitPanel(self.Tab, true)
		end)
	end
end

---------------------------------------------------------------- configs
local function encodeValue(control)
	local v = control.Value
	if control.Type == "ColorPicker" then
		return { Color = v:ToHex() }
	elseif control.Type == "Keybind" then
		return { Key = v and v.Name or "None", Mode = control.Mode }
	elseif control.Type == "PlayerPicker" then
		return { Player = v and v.Name or nil }
	elseif control.Type == "RangeSlider" then
		return { Range = { v.Min, v.Max } }
	elseif (control.Type == "Dropdown" or control.Type == "SearchSelect") and control.Multi then
		local picked = {}
		for k, on in v do
			if on then
				table.insert(picked, k)
			end
		end
		return { Multi = picked }
	end
	return { Value = v }
end

local function decodeValue(control, data, silent: boolean?)
	if control.Type == "ColorPicker" and data.Color then
		local ok, col = pcall(Color3.fromHex, data.Color)
		if ok then
			control:Set(col, silent)
		end
	elseif control.Type == "Keybind" and data.Key then
		control:Set(data.Key ~= "None" and data.Key or nil, silent)
	elseif (control.Type == "Dropdown" or control.Type == "SearchSelect") and data.Multi then
		control:Set(data.Multi, silent)
	elseif control.Type == "RangeSlider" and data.Range then
		control:Set(data.Range, silent)
	elseif control.Type == "PlayerPicker" then
		control:Set(data.Player, silent)
	elseif data.Value ~= nil and control.Set then
		control:Set(data.Value, silent)
	end
end

function Hub:_restoreRequiredControl(control)
	local value = control._requirementRestore
	control._requirementRestore = nil
	if value then pcall(decodeValue, control, value, true) end
end

local SAVABLE = { Toggle = true, Slider = true, Dropdown = true, Input = true, Keybind = true, ColorPicker = true, RangeSlider = true, Segmented = true, Stepper = true, PlayerPicker = true, ModuleCard = true, OrderList = true, SearchSelect = true, Accordion = true }

function Hub:_dir(): string
	return RiftUI.Folder .. "/" .. self.Id
end

function Hub:_configDir(): string
	return self:_dir() .. "/configs"
end

function Hub:_treeStateSnapshot()
	local result = {}
	for _, control in self._treeControls or {} do
		if not control._disposed and control.Persist ~= false and not control._internal and control.GetState then
			result[control.PersistKey] = control:GetState()
		end
	end
	return result
end

function Hub:_restoreTreeStates(states)
	if type(states) ~= "table" then return end
	for _, control in self._treeControls or {} do
		local state = states[control.PersistKey]
		if not control._disposed and type(state) == "table" then
			local ok, err = control:SetState(state, true)
			if not ok then recordError(tostring(err), nil, "tree-state restore") end
		end
	end
end

function Hub:_flagValues()
	local out = {}
	for flag, control in RiftUI.Flags do
		if control.Section and (control.Section.Hub == self or control.Section.Hub.Gui == self.Gui) and SAVABLE[control.Type] and not control._internal then
			out[flag] = encodeValue(control)
		end
	end
	return out
end

-- Optional authenticated config encryption. AES itself stays in the crypto provider.
local CONFIG_LIMIT = 256 * 1024
local CONFIG_ENCRYPTED = "riftui-encrypted-config"
local CONFIG_CIPHER = "AES-256-CBC-HMAC-SHA256"
local CONFIG_ENCRYPTED_PREFIX = "RIFTCFG2:"
local function configName(name)
	return type(name) == "string" and #name > 0 and #name <= 80 and string.match(name, "^[%w%s%-_]+$") ~= nil
end
local function hashBytes(provider, value)
	local hex = provider.hash(value, "sha256")
	assert(type(hex) == "string" and #hex == 64 and string.match(hex, "^%x+$"), "SHA-256 provider required")
	return (string.gsub(hex, "%x%x", function(pair) return string.char(tonumber(pair, 16)) end))
end
local function hmac(provider, key, value)
	if #key > 64 then key = hashBytes(provider, key) end
	key ..= string.rep("\0", 64 - #key)
	local inner, outer = {}, {}
	for i = 1, 64 do
		local b = string.byte(key, i)
		inner[i], outer[i] = string.char(bit32.bxor(b, 0x36)), string.char(bit32.bxor(b, 0x5c))
	end
	return hashBytes(provider, table.concat(outer) .. hashBytes(provider, table.concat(inner) .. value))
end
local function hexBytes(value)
	return (string.gsub(value, ".", function(c) return string.format("%02x", string.byte(c)) end))
end
local function sameTag(a, b)
	if type(a) ~= "string" or #a ~= #b then return false end
	local diff = 0
	for i = 1, #b do diff = bit32.bor(diff, bit32.bxor(string.byte(a, i), string.byte(b, i))) end
	return diff == 0
end
local function authenticatedText(envelope)
	return CONFIG_ENCRYPTED .. "\0" .. "1\0" .. CONFIG_CIPHER .. "\0" .. envelope.IV .. "\0" .. envelope.Ciphertext
end

function Hub:SetConfigEncryption(options)
	if options == nil or options == false then
		self._configEncryption, self._encryptConfigs = nil, false
		return true
	end
	if type(options) ~= "table" or (type(options.Key) ~= "string" and type(options.Key) ~= "function") then
		return false, "ConfigEncryption needs a 32-byte Base64 key or key provider"
	end
	local provider = options.Crypto or RiftUI.ConfigCrypto or (typeof(crypt) == "table" and crypt)
	for _, method in { "encrypt", "decrypt", "hash", "generatebytes", "base64encode", "base64decode" } do
		if type(provider) ~= "table" or type(provider[method]) ~= "function" then
			return false, "encrypted configs require an AES-CBC/SHA-256 crypto provider"
		end
	end
	self._configEncryption = { Key = options.Key, Crypto = provider }
	self._encryptConfigs = options.Enabled ~= false
	return true
end

function Hub:_configKeys(options)
	local configured = self._configEncryption
	local provider = (options and options.Crypto) or (configured and configured.Crypto) or RiftUI.ConfigCrypto or (typeof(crypt) == "table" and crypt)
	assert(type(provider) == "table", "crypto provider unavailable")
	local key = (options and options.Key) or (configured and configured.Key)
	if type(key) == "function" then key = key() end
	assert(type(key) == "string" and #key == 44 and string.match(key, "^[%w+/]+=$"), "a 32-byte Base64 key is required")
	local raw = provider.base64decode(key)
	assert(#raw == 32 and provider.base64encode(raw) == key, "a 32-byte Base64 key is required")
	-- Independent encryption and authentication keys derived from a random master key.
	return provider, provider.base64encode(hmac(provider, raw, "RiftUI config encryption v1")), hmac(provider, raw, "RiftUI config authentication v1")
end

function Hub:_encryptConfig(payload, options)
	local ok, envelope = pcall(function()
		local provider, aesKey, macKey = self:_configKeys(options)
		local json = HttpService:JSONEncode(payload)
		assert(#json <= CONFIG_LIMIT, "config too large")
		local iv = provider.generatebytes(16)
		assert(type(iv) == "string" and #provider.base64decode(iv) == 16, "invalid IV")
		local ciphertext = provider.encrypt(json, aesKey, iv, "CBC")
		assert(type(ciphertext) == "string" and #ciphertext <= CONFIG_LIMIT * 2, "invalid ciphertext")
		local bytes = provider.base64decode(ciphertext)
		assert(#bytes > 0 and #bytes % 16 == 0 and provider.base64encode(bytes) == ciphertext, "Base64 ciphertext required")
		local out = { Format = CONFIG_ENCRYPTED, Version = 1, Algorithm = CONFIG_CIPHER, IV = iv, Ciphertext = ciphertext }
		out.Tag = hexBytes(hmac(provider, macKey, authenticatedText(out)))
		return out
	end)
	if not ok then return nil, "couldn't encrypt config; check the key and crypto provider" end
	return envelope
end

function Hub:_decodeConfig(value, options)
	local original
	local ok, payload = pcall(function()
		if type(value) == "string" then
			assert(#value <= CONFIG_LIMIT * 2, "config too large")
			value = HttpService:JSONDecode(value)
		end
		assert(type(value) == "table", "invalid config")
		if value.Format == CONFIG_ENCRYPTED then
			original = value
			assert(value.Version == 1 and value.Algorithm == CONFIG_CIPHER, "unsupported encrypted config")
			assert(type(value.IV) == "string" and #value.IV == 24 and type(value.Ciphertext) == "string" and #value.Ciphertext <= CONFIG_LIMIT * 2, "invalid ciphertext")
			local provider, aesKey, macKey = self:_configKeys(options)
			assert(sameTag(value.Tag, hexBytes(hmac(provider, macKey, authenticatedText(value)))), "authentication failed")
			-- Verify the MAC before the AES provider sees ciphertext.
			local plain = provider.decrypt(value.Ciphertext, aesKey, value.IV, "CBC")
			assert(type(plain) == "string" and #plain <= CONFIG_LIMIT, "invalid plaintext")
			value = HttpService:JSONDecode(plain)
		end
		-- Plain local configs predate the sharing envelope.
		if value.Flags then
			assert(not (options and options.Remote), "remote config must identify its hub")
			value = { Hub = self.Id, Data = value }
		end
		assert(type(value) == "table" and value.Hub == self.Id and type(value.Data) == "table" and type(value.Data.Flags) == "table", "wrong hub or invalid config")
		local data = value.Data
		assert(data.Scale == nil or (type(data.Scale) == "number" and data.Scale == data.Scale), "invalid scale")
		assert(data.Pins == nil or type(data.Pins) == "table", "invalid pins")
		return value
	end)
	if not ok then return nil, "config is invalid, belongs to another hub, or its key/authentication is incorrect" end
	return payload, nil, original
end

function Hub:_writeConfig(name, payload, envelope)
	if not configName(name) then return false, "use up to 80 letters, numbers, spaces, - or _" end
	if not hasFS then return false, "this executor has no file functions" end
	local ok = pcall(function()
		ensureFolder(RiftUI.Folder) ensureFolder(self:_dir()) ensureFolder(self:_configDir())
		writefile(self:_configDir() .. "/" .. name .. ".json", HttpService:JSONEncode(envelope or payload.Data))
	end)
	if not ok then return false, "couldn't write config" end
	self:_configsChanged()
	return true, name
end

function Hub:_applyConfig(data)
	for flag, saved in data.Flags do
		local control = RiftUI.Flags[flag]
		if control and control.Section and (control.Section.Hub == self or control.Section.Hub.Gui == self.Gui) and type(saved) == "table" then pcall(decodeValue, control, saved) end
	end
	if type(data.TreeStates) == "table" then self:_restoreTreeStates(data.TreeStates) end
	if type(data.ToggleKey) == "string" then
		local ok, key = pcall(function() return Enum.KeyCode[data.ToggleKey] end)
		if ok and key then
			self.ToggleKey = key
			if self._toggleKeyControl then self._toggleKeyControl:Set(key, true) end
		end
	end
	if type(data.CommandKey) == "string" then
		local ok, key = pcall(function() return Enum.KeyCode[data.CommandKey] end)
		if ok and key then self:SetCommandKey(key) end
	end
	if data.Scale then self:SetScale(data.Scale) end
	if type(data.ColorTheme) == "string" then self:SetColorTheme(data.ColorTheme) end
	if data.ControlTheme == "Default" or data.ControlTheme == "Rounded" then
		self:SetControlTheme(data.ControlTheme)
	end
	if type(data.DesignTokens) == "table" then
		self:ResetDesignTokens(false)
		self:SetDesignTokens(data.DesignTokens)
	end
	if data.WeatherMode == "Screen" or data.WeatherMode == "UI" then self:SetWeatherMode(data.WeatherMode) end
	if type(data.WeatherDensity) == "number" then self:SetWeatherDensity(data.WeatherDensity) end
	if type(data.WeatherSpeed) == "number" then self:SetWeatherSpeed(data.WeatherSpeed) end
	if type(data.WeatherOpacity) == "number" then self:SetWeatherOpacity(data.WeatherOpacity) end
	if type(data.Weather) == "string" then self:SetWeather(data.Weather) end
	for _, tab in self.Tabs do
		for _, section in tab.Sections do
			local p = data.Pins and data.Pins[section.Id]
			if type(p) == "table" and type(p[1]) == "number" and type(p[2]) == "number" then
				section:Unpin() section:Pin(Vector2.new(p[1], p[2]))
			elseif section.Pinned then section:Unpin() end
		end
	end
	return true
end

function Hub:SetConfigServer(options)
	if options == nil then self._configServer = nil return true end
	local authority = type(options) == "table" and type(options.Url) == "string" and string.match(options.Url, "^https://([^/%s?#]+)")
	if not authority or string.find(authority, "@", 1, true) or string.find(options.Url, "[%s?#]") then
		return false, "config server must use an HTTPS base URL without credentials or query parameters"
	end
	if options.Token ~= nil and type(options.Token) ~= "string" and type(options.Token) ~= "function" then return false, "invalid token provider" end
	self._configServer = { Url = string.gsub(options.Url, "/+$", ""), Token = options.Token, RequireEncrypted = options.RequireEncrypted == true }
	return true
end

function Hub:LoadRemoteConfig(id, options)
	options = options or {}
	local server = self._configServer
	if not server then return false, "no config server configured" end
	if type(id) ~= "string" or #id > 80 or not string.match(id, "^[%w_-]+$") then return false, "invalid remote config ID" end
	if options.SaveAs and not configName(options.SaveAs) then return false, "invalid local config name" end
	local httpRequest = (typeof(request) == "function" and request) or (typeof(http_request) == "function" and http_request)
	if not httpRequest then return false, "remote configs require the request function" end
	local ok, response = pcall(function()
		local token = server.Token
		if type(token) == "function" then token = token(id) end
		local headers = { Accept = "application/json" }
		if token ~= nil then
			assert(type(token) == "string" and not string.find(token, "[\r\n]"), "invalid token")
			headers.Authorization = "Bearer " .. token
		end
		return httpRequest({ Url = server.Url .. "/configs/" .. id, Method = "GET", Headers = headers, Timeout = 15 })
	end)
	if not ok or type(response) ~= "table" then return false, "config server request failed; check connectivity and CORS in the simulator" end
	local status = tonumber(response.StatusCode) or 0
	if status < 200 or status >= 300 then return false, "config server returned HTTP " .. status end
	if type(response.Body) ~= "string" or #response.Body > CONFIG_LIMIT * 2 then return false, "config server returned an invalid or oversized body" end
	local decodeOptions = table.clone(options)
	decodeOptions.Remote = true
	local payload, err, envelope = self:_decodeConfig(response.Body, decodeOptions)
	if not payload then return false, err end
	if (server.RequireEncrypted or options.RequireEncrypted) and not envelope then return false, "this server requires encrypted configs" end
	-- Remote configs stay in memory unless the caller explicitly asks to cache one.
	if options.SaveAs then
		if not envelope and self._encryptConfigs then
			envelope, err = self:_encryptConfig(payload, options)
			if not envelope then return false, err end
		end
		local saved, saveError = self:_writeConfig(options.SaveAs, payload, envelope)
		if not saved then return false, saveError end
	end
	return self:_applyConfig(payload.Data)
end

function Hub:SaveConfig(name: string, options)
	name = tostring(name or "default")
	options = options or {}
	if not configName(name) then return false, "invalid config name" end
	local data = { Flags = self:_flagValues(), TreeStates = self:_treeStateSnapshot(), Pins = {}, ToggleKey = self.ToggleKey.Name, Scale = self._scale,
		ColorTheme = self:GetColorTheme(), ControlTheme = self:GetControlTheme(),
		DesignTokens = self:GetDesignTokenOverrides(),
		Weather = self:GetWeather(), WeatherMode = self:GetWeatherMode(),
		WeatherDensity = self:GetWeatherDensity(), WeatherSpeed = self:GetWeatherSpeed(),
		WeatherOpacity = self:GetWeatherOpacity(),
		CommandKey = self.CommandKey.Name, SavedAt = os.time() }
	for id, pos in self.Pins do data.Pins[id] = { pos.X, pos.Y } end
	local payload = { Hub = self.Id, Name = name, Data = data }
	local encrypted = options.Encrypt
	if encrypted == nil then encrypted = self._encryptConfigs end
	local envelope, err
	if encrypted then
		envelope, err = self:_encryptConfig(payload, options)
		if not envelope then return false, err end
	end
	return self:_writeConfig(name, payload, envelope)
end

-- Settings dropdowns and the config manager rebuild their lists through this.
function Hub:_configsChanged()
	for _, fn in self._configWatchers or {} do
		task.spawn(fn)
	end
end

function Hub:_watchConfigs(fn)
	self._configWatchers = self._configWatchers or {}
	table.insert(self._configWatchers, fn)
end

function Hub:LoadConfig(name: string, options)
	if not configName(name) then return false, "invalid config name" end
	if not hasFS then return false, "this executor has no file functions" end
	local path = self:_configDir() .. "/" .. name .. ".json"
	if not isfile(path) then return false, "no config named " .. name end
	local read, body = pcall(readfile, path)
	if not read then return false, "couldn't read config" end
	local payload, err = self:_decodeConfig(body, options)
	if not payload then return false, err end
	return self:_applyConfig(payload.Data)
end

function Hub:ListConfigs(): { string }
	local out = {}
	if not hasFS or typeof(listfiles) ~= "function" or not isfolder(self:_configDir()) then
		return out
	end
	for _, path in listfiles(self:_configDir()) do
		local name = string.match(path, "([^/\\]+)%.json$")
		if name then
			table.insert(out, name)
		end
	end
	table.sort(out)
	return out
end

function Hub:DeleteConfig(name: string): (boolean, string?)
	local path = self:_configDir() .. "/" .. tostring(name) .. ".json"
	if not (hasFS and typeof(delfile) == "function") then
		return false, "this executor can't delete files"
	end
	if not isfile(path) then
		return false, "no config named " .. tostring(name)
	end
	delfile(path)
	if self:GetAutoload() == name then
		self:SetAutoload(nil)
	end
	self:_configsChanged()
	return true
end

function Hub:RenameConfig(name: string, newName: string): (boolean, string?)
	newName = tostring(newName or "")
	if not string.match(newName, "^[%w%s%-_]+$") then
		return false, "use letters, numbers, spaces, - or _"
	end
	if not hasFS then
		return false, "this executor has no file functions"
	end
	local dir = self:_configDir()
	local from, to = dir .. "/" .. tostring(name) .. ".json", dir .. "/" .. newName .. ".json"
	if not isfile(from) then
		return false, "no config named " .. tostring(name)
	end
	if isfile(to) then
		return false, newName .. " already exists"
	end
	writefile(to, readfile(from))
	if typeof(delfile) == "function" then
		delfile(from)
	end
	if self:GetAutoload() == name then
		self:SetAutoload(newName)
	end
	self:_configsChanged()
	return true
end

-- Name, settings count and save time, read from the file without applying it.
function Hub:ConfigInfo(name: string)
	local path = self:_configDir() .. "/" .. tostring(name) .. ".json"
	if not hasFS or not isfile(path) then
		return nil
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return { Name = name, Damaged = true }
	end
	if data.Format == CONFIG_ENCRYPTED then
		-- Listing files never invokes key providers or decrypts each stored preset.
		return { Name = name, Encrypted = true, Locked = self._configEncryption == nil, Autoload = self:GetAutoload() == name }
	end
	local count = 0
	for _ in data.Flags or {} do
		count += 1
	end
	return { Name = name, Settings = count, SavedAt = data.SavedAt, Autoload = self:GetAutoload() == name }
end

function Hub:GetAutoload(): string?
	local path = self:_configDir() .. "/autoload.txt"
	if not hasFS or not isfile(path) then
		return nil
	end
	local name = readfile(path)
	return name ~= "" and name or nil
end

function Hub:SetAutoload(name: string?)
	if not hasFS then
		return
	end
	ensureFolder(RiftUI.Folder)
	ensureFolder(self:_dir())
	ensureFolder(self:_configDir())
	writefile(self:_configDir() .. "/autoload.txt", name or "")
	self:_configsChanged()
end

function Hub:_autoload()
	if not hasFS or self._replaying then
		return
	end
	local path = self:_configDir() .. "/autoload.txt"
	if isfile(path) then
		local name = readfile(path)
		if name ~= "" then
			local ok, err = self:LoadConfig(name)
			if ok then
				self:Notify({ Title = "Config loaded", Content = name, Duration = 3 })
			else
				recordError("autoload failed: " .. tostring(err), nil, "config")
			end
		end
	end
end

function Hub:SetScale(scale: number)
	scale = math.clamp(scale, 0.6, 1.5)
	self._scale = scale
	self.UIScale.Scale = scale
	if self._scaleControl then self._scaleControl:Set(math.floor(scale * 100 + 0.5), true) end
	if self._open then self:_fitPanel(self._open, false) end
	task.defer(function()
		if not self._destroyed and self._open then self:_fitPanel(self._open, false) end
	end)
end

---------------------------------------------------------------- developer mode
function RiftUI:SetDeveloperMode(on: boolean)
	RiftUI.DeveloperMode = on == true
	if hasFS then
		pcall(function()
			ensureFolder(RiftUI.Folder)
			writefile(devFile(), on and "1" or "0")
		end)
	end
	for _, hub in RiftUI.Hubs do
		if on then
			hub:_buildDeveloper()
		elseif hub.DeveloperTab then
			hub:_removeTab(hub.DeveloperTab)
			hub.DeveloperTab = nil
		end
	end
	notifyListeners()
end

function Hub:_removeTab(tab)
	if self._open == tab then
		self:Close()
	end
	for _, section in tab.Sections do
		section:Unpin()
		for _, c in section.Controls do
			if c.Flag and RiftUI.Flags[c.Flag] == c then
				RiftUI.Flags[c.Flag] = nil
			end
		end
	end
	tab.Tile:Destroy()
	task.delay(0.3, function()
		tab.Page:Destroy()
	end)
	local i = table.find(self.Tabs, tab)
	if i then
		table.remove(self.Tabs, i)
	end
	if tab._stateConn then
		tab._stateConn:Disconnect()
	end
end

local function countConnections(hub): number
	local n = 0
	for _, c in hub._conns do
		if c.Connected then
			n += 1
		end
	end
	return n
end

local SUNC = { "gethui", "cloneref", "getcustomasset", "writefile", "readfile", "isfile", "makefolder", "listfiles", "setclipboard", "request", "identifyexecutor" }
local function missingFunctions(): string
	local env = getfenv(1)
	local missing = {}
	for _, name in SUNC do
		if typeof(env[name]) ~= "function" then
			table.insert(missing, name)
		end
	end
	return #missing == 0 and "None. Every function RiftUI uses is available." or table.concat(missing, ", ")
end

function Hub:_buildDeveloper()
	if self.DeveloperTab or self.Options.Settings == false then
		return
	end
	local tab = self:Tab({ Name = "Developer", Icon = "bug", Description = "State machine, errors and tools", _internal = true, _order = 950 })
	self.DeveloperTab = tab
	local state = tab:Section({ Name = "State machine", Side = "Left" })
	local current = state:_info("Current", RiftUI.State)
	local history = state:Paragraph({ Title = "Transitions", Content = "", RichText = true })
	local diag = tab:Section({ Name = "Diagnostics", Side = "Left" })
	local inst = diag:_info("Instances", "0")
	local conns = diag:_info("Connections", "0")
	local flags = diag:_info("Flags", "0")
	local sheets = diag:_info("Icon sheets", "0")
	local missing = diag:Paragraph({ Title = "Missing sUNC functions", Content = missingFunctions() })

	local errs = tab:Section({ Name = "Errors", Side = "Right" })
	local errList = errs:Paragraph({ Title = "Captured errors", Content = "" })
	errs:Button({
		Name = "Copy errors",
		Callback = function()
			local lines = {}
			for _, e in RiftUI.Errors do
				table.insert(lines, string.format("[%.2fs] (%s) %s", e.Time, e.Source, e.Message))
				if e.Trace then
					table.insert(lines, e.Trace)
				end
			end
			if typeof(setclipboard) == "function" then
				setclipboard(table.concat(lines, "\n"))
				self:Notify({ Title = "Errors copied", Content = #RiftUI.Errors .. " entries", Duration = 2 })
			end
		end,
	})
	errs:Button({
		Name = "Clear errors",
		Callback = function()
			table.clear(RiftUI.Errors)
			notifyListeners()
		end,
	})
	local actions = tab:Section({ Name = "Actions", Side = "Right" })
	actions:Button({
		Name = "Reinitialize hub",
		Callback = function()
			self:Reinitialize()
		end,
	})
	actions:Button({
		Name = "Clear cached assets",
		Callback = function()
			if typeof(delfolder) == "function" and typeof(isfolder) == "function" and isfolder(RiftUI.Folder .. "/assets") then
				delfolder(RiftUI.Folder .. "/assets")
			end
			table.clear(Assets.sheets)
			Assets.shadow = nil
			Assets.failed = false
			self:Notify({ Title = "Assets cleared", Content = "They download again on the next Reinitialize.", Duration = 3 })
		end,
	})
	actions:Button({
		Name = "Throw a test error",
		Callback = function()
			xpcall(function()
				error("test error from Developer Mode")
			end, RiftUI.HandleError)
		end,
	})
	actions:Button({
		Name = "Disable Developer Mode",
		Danger = true,
		Callback = function()
			RiftUI:SetDeveloperMode(false)
		end,
	})

	local TONE = { Ready = "rgb(120,220,150)", Failed = "rgb(255,120,120)", Unloaded = "rgb(128,128,128)" }
	local function refresh()
		if not tab.Tile.Parent then
			return
		end
		current:Set(RiftUI.State)
		local lines = {}
		for i = #RiftUI.StateHistory, math.max(1, #RiftUI.StateHistory - 7), -1 do
			local e = RiftUI.StateHistory[i]
			local detail = e.Detail and ("  " .. string.sub(tostring(e.Detail), 1, 36)) or ""
			detail = string.gsub(string.gsub(detail, "<", "&lt;"), ">", "&gt;")
			table.insert(lines, string.format('<font color="%s">%s</font>  %.2fs%s', TONE[e.State] or "rgb(200,200,200)", e.State, e.Time, detail))
		end
		history:Set(nil, table.concat(lines, "\n"))
		local n = #RiftUI.Errors
		if n == 0 then
			errList:Set("Captured errors", "No errors recorded.")
		else
			local e = {}
			for i = n, math.max(1, n - 4), -1 do
				table.insert(e, string.format("%.2fs · %s · %s", RiftUI.Errors[i].Time, RiftUI.Errors[i].Source, string.sub(RiftUI.Errors[i].Message, 1, 120)))
			end
			errList:Set(string.format("Captured errors (%d)", n), table.concat(e, "\n"))
		end
		inst:Set(tostring(#self.Gui:GetDescendants()))
		conns:Set(tostring(countConnections(self)))
		local f = 0
		for _ in RiftUI.Flags do
			f += 1
		end
		flags:Set(tostring(f))
		local sh = 0
		for _ in Assets.sheets do
			sh += 1
		end
		sheets:Set(sh .. " / " .. ICON_INDEX.Sheets)
		missing:Set(nil, missingFunctions())
	end
	tab._stateConn = RiftUI:OnStateChanged(refresh)
	refresh()
	task.spawn(function()
		while tab.Tile.Parent do
			task.wait(1)
			if self._open == tab then
				refresh()
			end
		end
	end)
end

---------------------------------------------------------------- setup: first launch
--[[
	CreateHub({ Id = "rift-hub", Setup = { Options = { { Type = "Toggle", Name = "...", Flag = "...", Default = true } } } })

	The first time a hub runs (no RiftUI/<Id>/setup.json yet) it opens a setup window:
	toolbar key, theme, the hub's own setup options, then a compatibility check that calls
	each sUNC function RiftUI relies on and warns about anything that failed.
	Setup = false turns it off.
]]

function Hub:_setupOptions()
	local setup = self.Options.Setup
	return type(setup) == "table" and setup.Options or {}
end

-- Setup options exist as flags from the start, holding the saved (or default) value.
function Hub:_registerSetupFlags()
	local savedValues = self.SetupData and self.SetupData.Options or {}
	for _, opt in self:_setupOptions() do
		if opt.Flag and not RiftUI.Flags[opt.Flag] then
			local c = { Type = opt.Type, Name = opt.Name, Flag = opt.Flag, Value = opt.Default, _internal = true, _setup = true }
			if opt.Type == "Dropdown" and opt.Multi then
				c.Value = {}
				for _, v in opt.Default or {} do
					c.Value[v] = true
				end
				c.Multi = true
			end
			function c:Set(v)
				self.Value = v
			end
			function c:Get()
				return self.Value
			end
			RiftUI.Flags[opt.Flag] = c
			local data = savedValues[opt.Flag]
			if data then
				pcall(function()
					if data.Color then
						c.Value = Color3.fromHex(data.Color)
					elseif data.Key then
						c.Value = data.Key ~= "None" and Enum.KeyCode[data.Key] or nil
					elseif data.Multi then
						c.Value = {}
						for _, v in data.Multi do
							c.Value[v] = true
						end
					else
						c.Value = data.Value
					end
				end)
			end
		end
	end
end

local function needs(...)
	for _, name in { ... } do
		if typeof(getfenv(1)[name]) ~= "function" then
			error(name .. " isn't available", 0)
		end
	end
end

-- Each check calls the real function; Severity says how bad a failure is.
function Hub:_compatChecks()
	local dir = self:_dir()
	local probe = dir .. "/.rift-probe"
	local checks = {
		{ Name = "Hidden UI container", Detail = "gethui", Severity = "warn", Impact = "The hub falls back to CoreGui, where some games can find it.", Run = function()
			needs("gethui")
			assert(typeof(gethui()) == "Instance", "gethui didn't return an Instance")
		end },
		{ Name = "Safe references", Detail = "cloneref", Severity = "warn", Impact = "Services are used directly instead of through clones.", Run = function()
			needs("cloneref")
			assert(cloneref(game:GetService("Players")).Name == "Players", "cloneref returned a broken reference")
		end },
		{ Name = "Write and read files", Detail = "writefile · readfile", Severity = "fail", Impact = "Configs, setup and cached assets can't be saved.", Run = function()
			needs("writefile", "readfile", "isfile", "makefolder", "isfolder")
			ensureFolder(RiftUI.Folder)
			ensureFolder(dir)
			writefile(probe, "rift")
			assert(readfile(probe) == "rift", "readfile returned something else")
		end },
		{ Name = "List folders", Detail = "listfiles", Severity = "warn", Impact = "Saved configs won't appear in the Saved list.", Run = function()
			needs("listfiles")
			for _, path in listfiles(dir) do
				if string.find(path, "rift%-probe") then
					return
				end
			end
			error("listfiles didn't return the file it just wrote", 0)
		end },
		{ Name = "Custom assets", Detail = "getcustomasset", Severity = "fail", Impact = "Icons show as letters and shadows are missing.", Run = function()
			needs("getcustomasset", "writefile")
			ensureFolder(RiftUI.Folder) ensureFolder(dir)
			local imageProbe = probe .. ".png"
			-- Use a real PNG: image-only executors correctly reject the text file probe.
			writefile(imageProbe, "\137\080\078\071\013\010\026\010\000\000\000\013\073\072\068\082\000\000\000\001\000\000\000\001\008\006\000\000\000\031\021\196\137\000\000\000\013\073\068\065\084\120\218\099\100\096\248\095\015\000\002\135\001\128\235\071\186\146\000\000\000\000\073\069\078\068\174\066\096\130")
			local ok, id = pcall(getcustomasset, imageProbe)
			if typeof(delfile) == "function" then pcall(delfile, imageProbe) end
			assert(ok, tostring(id))
			assert(type(id) == "string" and #id > 0, "getcustomasset returned no content id")
		end },
		{ Name = "Delete files", Detail = "delfile", Severity = "warn", Impact = "Deleted configs stay in the workspace.", Run = function()
			needs("delfile")
			delfile(probe)
			assert(not isfile(probe), "the file is still there")
		end },
		{ Name = "Download assets", Detail = "game:HttpGet", Severity = "fail", Impact = "Icons and the shadow can't be downloaded.", Run = function()
			local body = game:HttpGet(RiftUI.AssetBase .. "assets/shadow.png")
			assert(type(body) == "string" and #body > 64, "the download came back empty")
		end },
		{ Name = "Clipboard", Detail = "setclipboard", Severity = "warn", Impact = "Copy buttons won't do anything.", Run = function()
			needs("setclipboard")
		end },
		{ Name = "Web requests", Detail = "request", Severity = "warn", Impact = "Hub features that call web APIs may not work.", Run = function()
			if typeof(request) ~= "function" and typeof(http_request) ~= "function" then
				error("request isn't available", 0)
			end
		end },
	}
	local ids = {}
	for id in self._requirements do table.insert(ids, id) end
	table.sort(ids)
	for _, id in ids do
		local spec = self._requirements[id]
		table.insert(checks, { Name = spec.Name, Detail = "developer test", Severity = "warn", Impact = "Features requiring " .. id .. " stay locked.", Run = function()
			local result = self:RunRequirement(id)
			assert(result and result.Passed, result and result.Message or "test cancelled")
		end })
	end
	return checks
end

function Hub:RunCompatibilityCheck()
	local results = {}
	for _, check in self:_compatChecks() do
		local ok, err = pcall(check.Run)
		table.insert(results, { Name = check.Name, Detail = check.Detail, Ok = ok, Severity = check.Severity, Error = not ok and tostring(err) or nil, Impact = check.Impact })
	end
	RiftUI.Compatibility = results
	return results
end

-- Recolour existing objects, retaining controls, focus, pins and captured theme references.
local THEME_PROPERTIES = { "BackgroundColor3", "TextColor3", "PlaceholderColor3", "ImageColor3", "ScrollBarImageColor3", "Color" }
local THEME_TOKENS = { "Text", "SubText", "Muted", "Accent", "AccentText", "Panel", "PanelStroke", "Tile", "TileHover", "TileActive", "TileStroke", "TileActiveStroke", "Section", "SectionStroke", "Divider", "Field", "FieldStroke", "Track", "Knob", "Highlight", "Danger", "Success", "Warning", "Scrim" }

function Hub:_transitionTheme(name, overrides)
	local nextTheme = buildTheme(name, overrides or self.Options.Theme)
	local old = table.clone(self.Theme)
	self._themeBindings = self._themeBindings or setmetatable({}, { __mode = "k" })
	self._themeScanned = self._themeScanned or setmetatable({}, { __mode = "k" })
	for _, tw in self._themeTweens or {} do tw:Cancel() end
	self._themeTweens = {}
	for _, inst in self.Gui:GetDescendants() do
		local ancestor, skip = inst, false
		while ancestor and ancestor ~= self.Gui do
			if ancestor:GetAttribute("ThemeSwatch") then skip = true break end
			ancestor = ancestor.Parent
		end
		if skip then continue end
		local tokens = self._themeBindings[inst] or {}
		local explicit = themeBindings[inst]
		if not self._themeScanned[inst] then
			for _, prop in THEME_PROPERTIES do
				local entry = explicit and explicit[prop]
				if entry and entry._theme == self.Theme then
					tokens[prop] = entry._key
				else
					local ok, value = pcall(function() return inst[prop] end)
					if ok and typeof(value) == "Color3" then
						for _, key in THEME_TOKENS do
							if value == old[key] then tokens[prop] = key break end
						end
					end
				end
			end
			self._themeScanned[inst] = true
		end
		if explicit then
			for prop, binding in explicit do
				if binding._theme == self.Theme then tokens[prop] = binding._key end
			end
		end
		self._themeBindings[inst] = tokens
		local goals = {}
		for prop, token in tokens do
			if nextTheme[token] and nextTheme[token] ~= old[token] then goals[prop] = nextTheme[token] end
		end
		if next(goals) then
            -- Token-bound properties are refreshed by Design Tokens v2 instead.
            -- Avoid an older palette tween overwriting an explicit new role.
            local tokenEntries = self._tokenBindings and self._tokenBindings[inst]
            if tokenEntries then
                for _, entry in tokenEntries do goals[entry.Property] = nil end
            end
            if next(goals) then table.insert(self._themeTweens, tween(inst, THEME_FADE, goals)) end
        end
	end
	for key, value in nextTheme do self.Theme[key] = value end
	self:_refreshDesignTokens()
	self:_refreshToolbarOrbTheme()
end

function Hub:SetTheme(name: string)
	self:_transitionTheme(name)
	self.ThemeName = name
	self.Options.ThemeName = name
	if self._themeControl then self._themeControl:Set(name, true) end
	if self._activeThemeInfo then self._activeThemeInfo:Set(name) end
	local data = self.SetupData or {}
	data.Theme = name
	data.ColorTheme = name
	self.SetupData = data
	if hasFS then
		pcall(function()
			ensureFolder(RiftUI.Folder)
			ensureFolder(self:_dir())
			writefile(self:_dir() .. "/setup.json", HttpService:JSONEncode(data))
		end)
	end
end

local function fitModal(hub, layer, holder, width, height, onResize)
	local function fit()
		local vp = viewport() / hub._scale
		local top = topInset() / hub._scale + 8
		local w, h = math.min(width, vp.X - 24), math.min(height, vp.Y - top - 16)
		holder.Size = UDim2.fromOffset(math.max(260, w), math.max(240, h))
		holder.Position = UDim2.fromOffset(vp.X / 2, top + h / 2)
		if onResize then onResize(w, h) end
	end
	local conn = layer:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	local scaleConn = hub.UIScale:GetPropertyChangedSignal("Scale"):Connect(fit)
	layer.Destroying:Connect(function() conn:Disconnect() scaleConn:Disconnect() end)
	fit()
end

---------------------------------------------------------------- preferences
-- Small per-hub choices (watermark, keybind list, language) live in setup.json.
function Hub:_savePref(key: string, value)
	self.SetupData = self.SetupData or {}
	self.SetupData[key] = value
	if hasFS then
		pcall(function()
			ensureFolder(RiftUI.Folder)
			ensureFolder(self:_dir())
			writefile(self:_dir() .. "/setup.json", HttpService:JSONEncode(self.SetupData))
		end)
	end
end

local function dragBy(hub, handle: GuiObject, target: GuiObject, onDrop)
	local start, origin
	return bindPointerDrag(hub, handle, {
		Start = function(input)
			start = Vector2.new(input.Position.X, input.Position.Y)
			origin = target.Position
		end,
		Move = function(input)
			local delta = (Vector2.new(input.Position.X, input.Position.Y) - start) / hub._scale
			target.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
		end,
		End = function(cancelled)
			start = nil
			if not cancelled and onDrop then onDrop(target.Position) end
		end,
	})
end

---------------------------------------------------------------- tooltips
-- Hovering a control for a moment shows its help text. Description fills in for controls
-- that don't print it under their name; Tooltip overrides it for any control.
function Hub:_attachTip(target: GuiObject, message: string)
	local token = 0
	self:_connect(target.MouseEnter, function()
		token += 1
		local mine = token
		task.delay(0.45, function()
			if mine ~= token or self._destroyed or self._popup then return end
			self:_showTip(target, message)
		end)
	end)
	self:_connect(target.MouseLeave, function()
		token += 1
		if self._tipFor == target then self:_hideTip() end
	end)
	self:_connect(target.InputBegan, function(input)
		if isPointer(input) then
			token += 1
			if self._tipFor == target then self:_hideTip() end
		end
	end)
end

function Hub:_showTip(target: GuiObject, message: string)
	local theme = self.Theme
	if not self._tip then
		self._tip = create("Frame", {
			Name = "ControlTip", BackgroundColor3 = themeColor(theme, "Panel"), Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY, Visible = false, ZIndex = 95, Parent = self.Overlay,
		}, { corner(8), stroke(themeColor(theme, "PanelStroke")), padding(7, 10) })
		self._tipText = text({ Parent = self._tip, Name = "Text", TextSize = 12, TextWrapped = true, LineHeight = 1.2, TextColor3 = themeColor(theme, "Text"), Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 96 })
		create("UISizeConstraint", { MaxSize = Vector2.new(260, 400), Parent = self._tipText })
		self._tipScale = create("UIScale", { Parent = self._tip })
	end
	self._tipFor = target
	self._tipText.Text = message
	local s = self._scale
	local pos, size = target.AbsolutePosition / s, target.AbsoluteSize / s
	local vp = viewport() / s
	self._tip.Visible = true
	task.defer(function()
		if self._tipFor ~= target or not self._tip then return end
		local ts = self._tip.AbsoluteSize / s
		local x = math.clamp(pos.X, 8, math.max(8, vp.X - ts.X - 8))
		local y = pos.Y + size.Y + 4
		if y + ts.Y > vp.Y - 8 then y = pos.Y - ts.Y - 4 end
		self._tip.Position = UDim2.fromOffset(x, y)
		self._tipScale.Scale = 1
	end)
end

function Hub:_hideTip()
	self._tipFor = nil
	if self._tip then self._tip.Visible = false end
end

---------------------------------------------------------------- watermark
--[[
	A thin strip in the corner: hub name, frame rate, ping and local time. It is drawn from
	the theme, never steals input except for dragging, and hides in stealth mode.
]]
function Hub:SetWatermark(on, quiet: boolean?)
	on = on ~= false and on ~= nil
	if self._watermarkControl then self._watermarkControl:Set(on, true) end
	if not quiet then self:_savePref("Watermark", on) end
	if not on then
		if self._watermark then
			local wm = self._watermark
			self._watermark = nil
			wm.Scale.Scale = 1
			tween(wm.Frame, FOLD, { BackgroundTransparency = 1 }).Completed:Connect(function() wm.Frame:Destroy() end)
			for _, conn in wm.Conns do conn:Disconnect() end
		end
		return
	end
	if self._watermark then return end
	local theme = self.Theme
	local saved = self.SetupData and self.SetupData.WatermarkPos
	local frame = create("Frame", {
		Name = "Watermark", BackgroundColor3 = themeColor(theme, "Panel"), BackgroundTransparency = 1,
		Position = saved and UDim2.fromOffset(saved[1], saved[2]) or UDim2.fromOffset(12, topInset() / self._scale + 10),
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, Active = true, ZIndex = 9, Parent = self.Gui,
	}, { corner(7), stroke(themeColor(theme, "PanelStroke")), padding(0, 10, 0, 8), list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local scale = create("UIScale", { Scale = 1, Parent = frame })
	if not hubMark(self.Icon, 14, theme, { LayoutOrder = 1, ZIndex = 10, Parent = frame }) then
		create("Frame", { Name = "Mark", BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromOffset(2, 12), LayoutOrder = 1, ZIndex = 10, Parent = frame }, { corner(1) })
	end
	text({ Parent = frame, Name = "HubName", Text = self.Name, TextSize = 12, FontFace = inter(Enum.FontWeight.SemiBold), Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, ZIndex = 10 })
	local order = 2
	local function field(name)
		order += 1
		text({ Parent = frame, Text = "·", TextSize = 12, TextColor3 = themeColor(theme, "Muted"), Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order, ZIndex = 10 })
		order += 1
		return text({ Parent = frame, Name = name, Text = "", FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "SubText"), Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order, ZIndex = 10 })
	end
	local fps, ping, clock = field("Fps"), field("Ping"), field("Time")
	local conns = {}
	local frames, elapsed = 0, 0
	local function update()
		local p
		pcall(function() p = Players.LocalPlayer:GetNetworkPing() end)
		local pingText = p and (math.floor(p * 2000 + 0.5) .. " ms") or "— ms"
		if ping.Text ~= pingText then ping.Text = pingText end
		local now = os.date("%H:%M")
		if clock.Text ~= now then clock.Text = now end
	end
	table.insert(conns, RunService.RenderStepped:Connect(function(dt)
		frames += 1
		elapsed += dt
		if elapsed >= 0.5 then
			local f = tostring(math.floor(frames / elapsed + 0.5)) .. " fps"
			if fps.Text ~= f then fps.Text = f end
			frames, elapsed = 0, 0
			update()
		end
	end))
	fps.Text = "— fps"
	update()
	self._watermark = { Frame = frame, Scale = scale, Conns = conns }
	dragBy(self, frame, frame, function(pos) self:_savePref("WatermarkPos", { pos.X.Offset, pos.Y.Offset }) end)
	frame.Visible = true
	tween(frame, SOFT, { BackgroundTransparency = 0.04 })
	tween(scale, RISE, { Scale = 1 })
end

---------------------------------------------------------------- keybind list
function Hub:_keybindControls()
	local out = {}
	local function scan(sections)
		for _, section in sections do
			for _, c in section.Controls do
				if c.Type == "Keybind" and not c._internal and c.Value ~= nil and not table.find(out, c) then
					table.insert(out, c)
				end
			end
		end
	end
	for _, tab in self.Tabs do scan(tab.Sections) end
	for _, win in self.Windows or {} do
		for _, tab in win.Tabs do scan(tab.Sections) end
	end
	return out
end

function Hub:_keybindsChanged()
	if not self._keylist or self._keylistQueued then return end
	self._keylistQueued = true
	task.defer(function()
		self._keylistQueued = false
		if self._keylist then self._keylist.Render() end
	end)
end

function Hub:SetKeybindList(on, quiet: boolean?)
	on = on ~= false and on ~= nil
	if self._keylistControl then self._keylistControl:Set(on, true) end
	if not quiet then self:_savePref("KeybindList", on) end
	if not on then
		if self._keylist then
			local kl = self._keylist
			self._keylist = nil
			kl.Scale.Scale = 1
			tween(kl.Frame, FOLD, { BackgroundTransparency = 1 }).Completed:Connect(function() kl.Frame:Destroy() end)
		end
		return
	end
	if self._keylist then return end
	local theme = self.Theme
	local saved = self.SetupData and self.SetupData.KeybindListPos
	local frame = create("Frame", {
		Name = "KeybindList", BackgroundColor3 = themeColor(theme, "Panel"), BackgroundTransparency = 1,
		Position = saved and UDim2.fromOffset(saved[1], saved[2]) or UDim2.fromOffset(12, topInset() / self._scale + 46),
		Size = UDim2.fromOffset(210, 0), AutomaticSize = Enum.AutomaticSize.Y, Active = true, ZIndex = 9, Parent = self.Gui,
	}, { corner(9), stroke(themeColor(theme, "PanelStroke")), padding(0, 10, 6, 10), list(Enum.FillDirection.Vertical, 0) })
	local scale = create("UIScale", { Scale = 1, Parent = frame })
	local head = create("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 0, ZIndex = 10, Parent = frame })
	iconLabel("keyboard", 13, theme.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), ZIndex = 11, Parent = head })
	text({ Parent = head, Text = "Keybinds", TextSize = 11, FontFace = inter(Enum.FontWeight.SemiBold), TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -20, 1, 0), ZIndex = 11 })
	create("Frame", { BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 11, Parent = head })
	local rows = {}
	local function render()
		for _, r in rows do r:Destroy() end
		table.clear(rows)
		local binds = self:_keybindControls()
		if #binds == 0 then
			table.insert(rows, text({ Parent = frame, Text = "No keybinds set", TextSize = 12, TextColor3 = themeColor(theme, "Muted"), Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1, ZIndex = 10 }))
		end
		for i, c in binds do
			local available = c:IsAvailable()
			local active = available and (c.State == true or c.Mode == "Always")
			local r = create("Frame", { Name = "Bind", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i, ZIndex = 10, Parent = frame })
			text({ Parent = r, Text = c.Name, TextSize = 12, TextColor3 = themeColor(theme, active and "Text" or "SubText"), Size = UDim2.new(1, -96, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 11 })
			create("TextLabel", {
				BackgroundColor3 = themeColor(theme, "Field"), Text = keyName(c.Value), FontFace = MONO, TextSize = 10, TextColor3 = themeColor(theme, "SubText"),
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -44, 0.5, 0), Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 11, Parent = r,
			}, { corner(4), stroke(themeColor(theme, "FieldStroke")), padding(0, 5), create("UISizeConstraint", { MaxSize = Vector2.new(70, 18) }) })
			local state = not available and "Locked" or c.Mode == "Always" and "Always" or (c.Mode == "Hold" and (active and "Held" or "Hold") or (active and "On" or "Off"))
			text({ Parent = r, Text = state, FontFace = inter(Enum.FontWeight.Medium), TextSize = 11, TextColor3 = themeColor(theme, active and "Accent" or "Muted"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 40, 1, 0), ZIndex = 11 })
			table.insert(rows, r)
		end
	end
	self._keylist = { Frame = frame, Scale = scale, Render = render }
	render()
	dragBy(self, head, frame, function(pos) self:_savePref("KeybindListPos", { pos.X.Offset, pos.Y.Offset }) end)
	frame.Visible = true
	tween(frame, SOFT, { BackgroundTransparency = 0.04 })
	tween(scale, RISE, { Scale = 1 })
end

---------------------------------------------------------------- translations
--[[
	Every label the hub draws passes through the active language. Keys are the English text;
	"{n}"-style keys match text with a changing part, so "{n} results" covers "12 results".
	Hubs add their own strings with CreateHub{ Translations = { es = { ["Aim Assist"] = "…" } } }.
]]
RiftUI.LanguageNames = { en = "English", es = "Español", pt = "Português", de = "Deutsch", fr = "Français" }
RiftUI.Translations = {
	es = {
		["Settings"] = "Ajustes", ["Toolbar, configs and about"] = "Barra, configuraciones e información", ["Interface"] = "Interfaz", ["Config"] = "Configuración",
		["Toolbar key"] = "Tecla de la barra", ["Command palette key"] = "Tecla de búsqueda", ["Interface scale"] = "Escala de interfaz", ["Theme"] = "Tema",
		["Open theme studio"] = "Abrir estudio de temas", ["Stealth mode"] = "Modo sigilo", ["Local assets only, built-in font fallback, quiet library output"] = "Solo recursos locales, fuente integrada y biblioteca silenciosa",
		["Watermark"] = "Marca de agua", ["Hub name, FPS, ping and time"] = "Nombre, FPS, ping y hora", ["Keybind list"] = "Lista de teclas", ["Bound keys and their state"] = "Teclas asignadas y su estado", ["Language"] = "Idioma",
		["Config name"] = "Nombre", ["Save"] = "Guardar", ["Saved"] = "Guardadas", ["Load selected"] = "Cargar selección", ["Autoload a config"] = "Cargar al iniciar",
		["Loads on start, before the toolbar shows"] = "Se aplica al iniciar, antes de mostrar la barra", ["Autoload config"] = "Configuración inicial", ["Manage configs"] = "Gestionar configuraciones",
		["Version"] = "Versión", ["Executor"] = "Ejecutor", ["Hub ID"] = "ID del hub", ["Run setup again"] = "Repetir configuración inicial", ["Unload hub"] = "Descargar hub", ["None"] = "Ninguna",
		["Search tabs, settings and controls"] = "Buscar pestañas, ajustes y controles", ["Recent"] = "Recientes", ["Jump to"] = "Ir a", ["Windows"] = "Ventanas", ["Actions"] = "Acciones",
		["Move"] = "Mover", ["Open"] = "Abrir", ["Close"] = "Cerrar", ["Type to search every control"] = "Escribe para buscar cualquier control", ["Tap a result to jump to it"] = "Toca un resultado para ir a él",
		["No results"] = "Sin resultados", ["{n} results"] = "{n} resultados", ["1 result"] = "1 resultado", ["Hide toolbar"] = "Ocultar barra", ["Show toolbar"] = "Mostrar barra", ["Close panel"] = "Cerrar panel",
		["Configs"] = "Configuraciones", ["Save, load and share setups for {hub}"] = "Guarda, carga y comparte ajustes de {hub}", ["Share"] = "Compartir", ["Saved configs"] = "Guardadas", ["Selected"] = "Seleccionada",
		["Load"] = "Cargar", ["Save current settings here"] = "Sobrescribir con los ajustes actuales", ["Load on start"] = "Cargar al iniciar", ["Applied when the hub starts"] = "Se aplica al iniciar el hub",
		["Rename to"] = "Renombrar a", ["New name"] = "Nuevo nombre", ["Rename"] = "Renombrar", ["Delete"] = "Eliminar", ["New config"] = "Nueva configuración", ["Name"] = "Nombre",
		["Save current settings"] = "Guardar ajustes actuales", ["Export"] = "Exportar", ["Copy share code"] = "Copiar código", ["Import"] = "Importar", ["Share code"] = "Código", ["Save as"] = "Guardar como",
		["Keep original name"] = "Mantener el nombre", ["No configs yet. Save one under New config."] = "Aún no hay configuraciones. Guarda una en Nueva configuración.",
		["Keybinds"] = "Teclas", ["On"] = "Activo", ["Off"] = "Inactivo", ["Held"] = "Pulsada", ["Hold"] = "Mantener", ["Always"] = "Siempre", ["No keybinds set"] = "No hay teclas asignadas",
		["Config saved"] = "Configuración guardada", ["Config loaded"] = "Configuración cargada", ["Autoload set"] = "Carga automática lista", ["Cancel"] = "Cancelar", ["OK"] = "Aceptar",
		["Nothing logged yet"] = "Sin registros", ["Search players"] = "Buscar jugadores", ["Left the game"] = "Salió del juego", ["Nobody else is here"] = "No hay nadie más", ["No match"] = "Sin coincidencias",
		["{n} settings · {when}"] = "{n} ajustes · {when}", ["saved just now"] = "guardada ahora", ["saved {n} min ago"] = "guardada hace {n} min", ["saved {n} h ago"] = "guardada hace {n} h", ["saved {n} d ago"] = "guardada hace {n} d", ["{when} · loads on start"] = "{when} · se carga al iniciar",
	},
	pt = {
		["Settings"] = "Configurações", ["Toolbar, configs and about"] = "Barra, perfis e sobre", ["Interface"] = "Interface", ["Config"] = "Perfil",
		["Toolbar key"] = "Tecla da barra", ["Command palette key"] = "Tecla de busca", ["Interface scale"] = "Escala da interface", ["Theme"] = "Tema",
		["Open theme studio"] = "Abrir estúdio de temas", ["Stealth mode"] = "Modo furtivo", ["Local assets only, built-in font fallback, quiet library output"] = "Apenas recursos locais, fonte interna e biblioteca silenciosa",
		["Watermark"] = "Marca d'água", ["Hub name, FPS, ping and time"] = "Nome, FPS, ping e hora", ["Keybind list"] = "Lista de teclas", ["Bound keys and their state"] = "Teclas definidas e seu estado", ["Language"] = "Idioma",
		["Config name"] = "Nome", ["Save"] = "Salvar", ["Saved"] = "Salvos", ["Load selected"] = "Carregar selecionado", ["Autoload a config"] = "Carregar ao iniciar",
		["Loads on start, before the toolbar shows"] = "Aplicado ao iniciar, antes da barra aparecer", ["Autoload config"] = "Perfil inicial", ["Manage configs"] = "Gerenciar perfis",
		["Version"] = "Versão", ["Executor"] = "Executor", ["Hub ID"] = "ID do hub", ["Run setup again"] = "Refazer configuração inicial", ["Unload hub"] = "Descarregar hub", ["None"] = "Nenhum",
		["Search tabs, settings and controls"] = "Buscar abas, configurações e controles", ["Recent"] = "Recentes", ["Jump to"] = "Ir para", ["Windows"] = "Janelas", ["Actions"] = "Ações",
		["Move"] = "Mover", ["Open"] = "Abrir", ["Close"] = "Fechar", ["Type to search every control"] = "Digite para buscar qualquer controle", ["Tap a result to jump to it"] = "Toque em um resultado para ir até ele",
		["No results"] = "Nenhum resultado", ["{n} results"] = "{n} resultados", ["1 result"] = "1 resultado", ["Hide toolbar"] = "Ocultar barra", ["Show toolbar"] = "Mostrar barra", ["Close panel"] = "Fechar painel",
		["Configs"] = "Perfis", ["Save, load and share setups for {hub}"] = "Salve, carregue e compartilhe perfis de {hub}", ["Share"] = "Compartilhar", ["Saved configs"] = "Perfis salvos", ["Selected"] = "Selecionado",
		["Load"] = "Carregar", ["Save current settings here"] = "Sobrescrever com as configurações atuais", ["Load on start"] = "Carregar ao iniciar", ["Applied when the hub starts"] = "Aplicado quando o hub inicia",
		["Rename to"] = "Renomear para", ["New name"] = "Novo nome", ["Rename"] = "Renomear", ["Delete"] = "Excluir", ["New config"] = "Novo perfil", ["Name"] = "Nome",
		["Save current settings"] = "Salvar configurações atuais", ["Export"] = "Exportar", ["Copy share code"] = "Copiar código", ["Import"] = "Importar", ["Share code"] = "Código", ["Save as"] = "Salvar como",
		["Keep original name"] = "Manter o nome", ["No configs yet. Save one under New config."] = "Nenhum perfil ainda. Salve um em Novo perfil.",
		["Keybinds"] = "Teclas", ["On"] = "Ligado", ["Off"] = "Desligado", ["Held"] = "Segurando", ["Hold"] = "Segurar", ["Always"] = "Sempre", ["No keybinds set"] = "Nenhuma tecla definida",
		["Config saved"] = "Perfil salvo", ["Config loaded"] = "Perfil carregado", ["Autoload set"] = "Carregamento automático definido", ["Cancel"] = "Cancelar", ["OK"] = "OK",
		["Nothing logged yet"] = "Nada registrado", ["Search players"] = "Buscar jogadores", ["Left the game"] = "Saiu do jogo", ["Nobody else is here"] = "Ninguém mais aqui", ["No match"] = "Nada encontrado",
		["{n} settings · {when}"] = "{n} ajustes · {when}", ["saved just now"] = "salvo agora", ["saved {n} min ago"] = "salvo há {n} min", ["saved {n} h ago"] = "salvo há {n} h", ["saved {n} d ago"] = "salvo há {n} d", ["{when} · loads on start"] = "{when} · carrega ao iniciar",
	},
	de = {
		["Settings"] = "Einstellungen", ["Toolbar, configs and about"] = "Leiste, Profile und Info", ["Interface"] = "Oberfläche", ["Config"] = "Profil",
		["Toolbar key"] = "Leistentaste", ["Command palette key"] = "Suchtaste", ["Interface scale"] = "Skalierung", ["Theme"] = "Design",
		["Open theme studio"] = "Design-Studio öffnen", ["Stealth mode"] = "Tarnmodus", ["Local assets only, built-in font fallback, quiet library output"] = "Nur lokale Assets, integrierte Schrift und stille Bibliothek",
		["Watermark"] = "Wasserzeichen", ["Hub name, FPS, ping and time"] = "Name, FPS, Ping und Uhrzeit", ["Keybind list"] = "Tastenliste", ["Bound keys and their state"] = "Belegte Tasten und ihr Zustand", ["Language"] = "Sprache",
		["Config name"] = "Name", ["Save"] = "Speichern", ["Saved"] = "Gespeichert", ["Load selected"] = "Auswahl laden", ["Autoload a config"] = "Beim Start laden",
		["Loads on start, before the toolbar shows"] = "Wird beim Start geladen, bevor die Leiste erscheint", ["Autoload config"] = "Startprofil", ["Manage configs"] = "Profile verwalten",
		["Version"] = "Version", ["Executor"] = "Executor", ["Hub ID"] = "Hub-ID", ["Run setup again"] = "Einrichtung wiederholen", ["Unload hub"] = "Hub entladen", ["None"] = "Keins",
		["Search tabs, settings and controls"] = "Tabs, Einstellungen und Regler suchen", ["Recent"] = "Zuletzt", ["Jump to"] = "Springen zu", ["Windows"] = "Fenster", ["Actions"] = "Aktionen",
		["Move"] = "Bewegen", ["Open"] = "Öffnen", ["Close"] = "Schließen", ["Type to search every control"] = "Tippen, um alles zu durchsuchen", ["Tap a result to jump to it"] = "Ergebnis antippen, um hinzuspringen",
		["No results"] = "Keine Treffer", ["{n} results"] = "{n} Treffer", ["1 result"] = "1 Treffer", ["Hide toolbar"] = "Leiste ausblenden", ["Show toolbar"] = "Leiste einblenden", ["Close panel"] = "Panel schließen",
		["Configs"] = "Profile", ["Save, load and share setups for {hub}"] = "Profile für {hub} speichern, laden und teilen", ["Share"] = "Teilen", ["Saved configs"] = "Gespeicherte Profile", ["Selected"] = "Ausgewählt",
		["Load"] = "Laden", ["Save current settings here"] = "Mit aktuellen Werten überschreiben", ["Load on start"] = "Beim Start laden", ["Applied when the hub starts"] = "Wird beim Start des Hubs angewendet",
		["Rename to"] = "Umbenennen in", ["New name"] = "Neuer Name", ["Rename"] = "Umbenennen", ["Delete"] = "Löschen", ["New config"] = "Neues Profil", ["Name"] = "Name",
		["Save current settings"] = "Aktuelle Werte speichern", ["Export"] = "Exportieren", ["Copy share code"] = "Code kopieren", ["Import"] = "Importieren", ["Share code"] = "Code", ["Save as"] = "Speichern als",
		["Keep original name"] = "Namen beibehalten", ["No configs yet. Save one under New config."] = "Noch keine Profile. Speichere eins unter Neues Profil.",
		["Keybinds"] = "Tasten", ["On"] = "An", ["Off"] = "Aus", ["Held"] = "Gehalten", ["Hold"] = "Halten", ["Always"] = "Immer", ["No keybinds set"] = "Keine Tasten belegt",
		["Config saved"] = "Profil gespeichert", ["Config loaded"] = "Profil geladen", ["Autoload set"] = "Startprofil gesetzt", ["Cancel"] = "Abbrechen", ["OK"] = "OK",
		["Nothing logged yet"] = "Noch keine Einträge", ["Search players"] = "Spieler suchen", ["Left the game"] = "Hat das Spiel verlassen", ["Nobody else is here"] = "Sonst ist niemand hier", ["No match"] = "Kein Treffer",
		["{n} settings · {when}"] = "{n} Werte · {when}", ["saved just now"] = "gerade gespeichert", ["saved {n} min ago"] = "vor {n} Min. gespeichert", ["saved {n} h ago"] = "vor {n} Std. gespeichert", ["saved {n} d ago"] = "vor {n} T. gespeichert", ["{when} · loads on start"] = "{when} · lädt beim Start",
	},
	fr = {
		["Settings"] = "Réglages", ["Toolbar, configs and about"] = "Barre, profils et infos", ["Interface"] = "Interface", ["Config"] = "Profil",
		["Toolbar key"] = "Touche de la barre", ["Command palette key"] = "Touche de recherche", ["Interface scale"] = "Échelle", ["Theme"] = "Thème",
		["Open theme studio"] = "Ouvrir le studio de thèmes", ["Stealth mode"] = "Mode discret", ["Local assets only, built-in font fallback, quiet library output"] = "Ressources locales, police intégrée et bibliothèque silencieuse",
		["Watermark"] = "Filigrane", ["Hub name, FPS, ping and time"] = "Nom, FPS, ping et heure", ["Keybind list"] = "Liste des touches", ["Bound keys and their state"] = "Touches assignées et leur état", ["Language"] = "Langue",
		["Config name"] = "Nom", ["Save"] = "Enregistrer", ["Saved"] = "Enregistrés", ["Load selected"] = "Charger la sélection", ["Autoload a config"] = "Charger au lancement",
		["Loads on start, before the toolbar shows"] = "Appliqué au lancement, avant l'affichage de la barre", ["Autoload config"] = "Profil de départ", ["Manage configs"] = "Gérer les profils",
		["Version"] = "Version", ["Executor"] = "Exécuteur", ["Hub ID"] = "ID du hub", ["Run setup again"] = "Relancer la configuration", ["Unload hub"] = "Décharger le hub", ["None"] = "Aucun",
		["Search tabs, settings and controls"] = "Rechercher onglets, réglages et contrôles", ["Recent"] = "Récents", ["Jump to"] = "Aller à", ["Windows"] = "Fenêtres", ["Actions"] = "Actions",
		["Move"] = "Naviguer", ["Open"] = "Ouvrir", ["Close"] = "Fermer", ["Type to search every control"] = "Tapez pour chercher un contrôle", ["Tap a result to jump to it"] = "Touchez un résultat pour y aller",
		["No results"] = "Aucun résultat", ["{n} results"] = "{n} résultats", ["1 result"] = "1 résultat", ["Hide toolbar"] = "Masquer la barre", ["Show toolbar"] = "Afficher la barre", ["Close panel"] = "Fermer le panneau",
		["Configs"] = "Profils", ["Save, load and share setups for {hub}"] = "Enregistrez, chargez et partagez les profils de {hub}", ["Share"] = "Partager", ["Saved configs"] = "Profils enregistrés", ["Selected"] = "Sélection",
		["Load"] = "Charger", ["Save current settings here"] = "Écraser avec les réglages actuels", ["Load on start"] = "Charger au lancement", ["Applied when the hub starts"] = "Appliqué au lancement du hub",
		["Rename to"] = "Renommer en", ["New name"] = "Nouveau nom", ["Rename"] = "Renommer", ["Delete"] = "Supprimer", ["New config"] = "Nouveau profil", ["Name"] = "Nom",
		["Save current settings"] = "Enregistrer les réglages actuels", ["Export"] = "Exporter", ["Copy share code"] = "Copier le code", ["Import"] = "Importer", ["Share code"] = "Code", ["Save as"] = "Enregistrer sous",
		["Keep original name"] = "Garder le nom", ["No configs yet. Save one under New config."] = "Aucun profil. Enregistrez-en un dans Nouveau profil.",
		["Keybinds"] = "Touches", ["On"] = "Actif", ["Off"] = "Inactif", ["Held"] = "Maintenue", ["Hold"] = "Maintenir", ["Always"] = "Toujours", ["No keybinds set"] = "Aucune touche assignée",
		["Config saved"] = "Profil enregistré", ["Config loaded"] = "Profil chargé", ["Autoload set"] = "Chargement auto défini", ["Cancel"] = "Annuler", ["OK"] = "OK",
		["Nothing logged yet"] = "Rien pour l'instant", ["Search players"] = "Rechercher des joueurs", ["Left the game"] = "A quitté la partie", ["Nobody else is here"] = "Personne d'autre ici", ["No match"] = "Aucun résultat",
		["{n} settings · {when}"] = "{n} réglages · {when}", ["saved just now"] = "enregistré à l'instant", ["saved {n} min ago"] = "enregistré il y a {n} min", ["saved {n} h ago"] = "enregistré il y a {n} h", ["saved {n} d ago"] = "enregistré il y a {n} j", ["{when} · loads on start"] = "{when} · chargé au lancement",
	},
}

-- SPDX-License-Identifier: MPL-2.0
-- Built-in Simplified Chinese localization. Loaded after the core dictionaries.
-- English source keys stay unchanged for fallback and user-supplied overrides.
RiftUI.LanguageNames.zh = "简体中文"
RiftUI.Translations.zh = {
	["Settings"] = "设置",
	["Toolbar, configs and about"] = "工具栏、配置与关于",
	["Interface"] = "界面",
	["Config"] = "配置",
	["Toolbar key"] = "工具栏快捷键",
	["Command palette key"] = "命令面板快捷键",
	["Interface scale"] = "界面缩放",
	["Color theme"] = "颜色主题",
	["Control theme"] = "控件主题",
	["Current theme"] = "当前主题",
	["Interaction feedback"] = "交互反馈",
	["Subtle interface sound feedback"] = "轻量界面交互音效",
	["Background appearance"] = "背景外观",
	["Background readability"] = "背景可读性遮罩",
	["Weather effects"] = "天气特效",
	["Sort: none"] = "排序：无",
	["Sort: {name}"] = "排序：{name}",
	["{shown} / {total}   ·   page {page}/{pages}"] = "{shown}/{total} 条 · 第 {page}/{pages} 页",
	["Default"] = "默认",
	["Rounded"] = "圆润",
	["Open theme studio"] = "打开主题工作室",
	["Stealth mode"] = "隐匿模式",
	["Local assets only, built-in font fallback, quiet library output"] = "仅使用本地资源、内置字体回退并减少日志输出",
	["Watermark"] = "水印",
	["Hub name, FPS, ping and time"] = "显示 Hub 名称、FPS、延迟和时间",
	["Keybind list"] = "快捷键列表",
	["Bound keys and their state"] = "显示已绑定按键及其状态",
	["Language"] = "语言",
	["Config name"] = "配置名称",
	["Save"] = "保存",
	["Saved"] = "已保存",
	["Load selected"] = "加载所选配置",
	["Autoload a config"] = "自动加载配置",
	["Loads on start, before the toolbar shows"] = "启动时、工具栏显示前加载",
	["Autoload config"] = "自动加载的配置",
	["Manage configs"] = "管理配置",
	["Version"] = "版本",
	["Executor"] = "执行器",
	["Hub ID"] = "Hub 标识",
	["Run setup again"] = "重新运行初始化向导",
	["Unload hub"] = "卸载 Hub",
	["None"] = "无",
	["Search tabs, settings and controls"] = "搜索分页、设置和控件",
	["Recent"] = "最近使用",
	["Jump to"] = "跳转到",
	["Windows"] = "窗口",
	["Actions"] = "操作",
	["Move"] = "移动",
	["Open"] = "打开",
	["Close"] = "关闭",
	["Type to search every control"] = "输入内容以搜索所有控件",
	["Tap a result to jump to it"] = "点击搜索结果以跳转",
	["No results"] = "没有搜索结果",
	["{n} results"] = "{n} 个结果",
	["1 result"] = "1 个结果",
	["Hide toolbar"] = "隐藏工具栏",
	["Show toolbar"] = "显示工具栏",
	["Close panel"] = "关闭面板",
	["Configs"] = "配置管理",
	["Save, load and share setups for {hub}"] = "保存、加载和分享 {hub} 的配置",
	["Share"] = "分享",
	["Saved configs"] = "已保存的配置",
	["Selected"] = "已选中",
	["Load"] = "加载",
	["Save current settings here"] = "将当前设置保存到此配置",
	["Load on start"] = "启动时加载",
	["Applied when the hub starts"] = "Hub 启动时应用",
	["Rename to"] = "重命名为",
	["New name"] = "新名称",
	["Rename"] = "重命名",
	["Delete"] = "删除",
	["New config"] = "新建配置",
	["Name"] = "名称",
	["Save current settings"] = "保存当前设置",
	["Export"] = "导出",
	["Copy share code"] = "复制分享码",
	["Import"] = "导入",
	["Share code"] = "分享码",
	["Save as"] = "另存为",
	["Keep original name"] = "保留原名称",
	["No configs yet. Save one under New config."] = "暂无配置。请在“新建配置”中保存。",
	["Keybinds"] = "快捷键",
	["On"] = "开启",
	["Off"] = "关闭",
	["Held"] = "按住中",
	["Hold"] = "按住",
	["Always"] = "始终开启",
	["No keybinds set"] = "尚未设置快捷键",
	["Config saved"] = "配置已保存",
	["Config loaded"] = "配置已加载",
	["Autoload set"] = "已设置自动加载",
	["Cancel"] = "取消",
	["OK"] = "确定",
	["Nothing logged yet"] = "暂无日志",
	["Search players"] = "搜索玩家",
	["Left the game"] = "已离开游戏",
	["Nobody else is here"] = "这里没有其他玩家",
	["No match"] = "没有匹配项",
	["{n} settings · {when}"] = "{n} 项设置 · {when}",
	["saved just now"] = "刚刚保存",
	["saved {n} min ago"] = "{n} 分钟前保存",
	["saved {n} h ago"] = "{n} 小时前保存",
	["saved {n} d ago"] = "{n} 天前保存",
	["{when} · loads on start"] = "{when} · 启动时自动加载",
	["UI sounds"] = "界面音效",
	["Vanta-style interface feedback"] = "Vanta 风格交互音效",
	["UI sound preset"] = "音效预设",
	["UI sound volume"] = "音效音量",
	["Background preset"] = "背景预设",
	["UI background"] = "UI背景",
	["UI background opacity"] = "UI背景不透明度",
	["Background switching"] = "背景切换",
	["Weather effect"] = "天气效果",
	["Weather area"] = "天气区域",
	["Weather density"] = "粒子密度",
	["Weather speed"] = "天气速度",
	["Weather opacity"] = "天气不透明度",
	["Weather unavailable"] = "天气效果不可用",
	["Screen"] = "全屏",
	["Rain"] = "下雨",
	["Snow"] = "飘雪",
	["Ember"] = "余烬",
	["Sakura"] = "樱花",
	["Fireflies"] = "萤火虫",
	["Matrix"] = "代码雨",
	["Transition mode"] = "切换动画",
	["Crossfade"] = "交叉渐变",
	["Fade"] = "淡出淡入",
	["Instant"] = "即时切换",
	["Background URL or file"] = "背景链接或文件",
	["Apply background"] = "应用背景",
	["Clear background"] = "清除背景",
	["Switch to a preset, Roblox asset, image URL or local file"] = "从预设、Roblox 资源、图片链接或本地文件切换",

	["Background unavailable"] = "背景不可用",
	["Background opacity"] = "背景不透明度",
	["Soft"] = "柔和",
	["Minimal"] = "极简",
	["Deep Violet"] = "深紫色",
	["Blood Red"] = "暗红色",
	["Cyanic"] = "青蓝色",
	["Amber Glow"] = "琥珀光晕",
	["Bloomings"] = "繁花",
	["Lavender Pink"] = "薰衣草粉",
	["About"] = "关于",
	["Feature requirements"] = "功能运行条件",
	["Recheck feature requirements"] = "重新检查功能运行条件",
	["Available"] = "可用",
	["Unavailable"] = "不可用",
	["Checking…"] = "检查中…",
	["e.g. legit"] = "例如：常用配置",
	["Couldn't save"] = "保存失败",
	["Couldn't load"] = "加载失败",
	["Stealth mode is controlled by this script."] = "隐匿模式由当前脚本控制。",
	["Script: On"] = "脚本：开启",
	["Script: Off"] = "脚本：关闭",
	["This script is powered by RiftUI. Licensed under MPL-2.0"] = "本脚本使用 RiftUI 构建，采用 MPL-2.0 许可证。",
	["Copy GitHub link"] = "复制 GitHub 链接",
	["Link copied"] = "链接已复制",
	["Developer Mode is on"] = "开发者模式已开启",
	["Find it in the Developer tab."] = "可在“开发者”分页中找到。",
	["Enable Developer Mode?"] = "启用开发者模式？",
	["Adds a Developer tab with the hub's state machine, every captured error and tools like Reinitialize. It's meant for hub authors and stays on until you turn it off."] = "增加“开发者”分页，显示 Hub 状态、捕获的错误和重新初始化工具。此功能面向开发者，关闭前将持续启用。",
	["Enable"] = "启用",
	["Hub reinitialized"] = "Hub 已重新初始化",
	["Theme studio"] = "主题工作室",
	["Colours and background for "] = "颜色与背景：",
	["Controls"] = "控件",
	["Preview"] = "预览",
	["Combat"] = "战斗",
	["Aim assist"] = "瞄准辅助",
	["Field of view"] = "视野范围",
	["Look"] = "外观",
	["Base theme"] = "基础主题",
	["Accent"] = "强调色",
	["Background image"] = "背景图片",
	["Source"] = "来源",
	["No background image."] = "暂无背景图片。",
	["Image URL"] = "图片链接",
	["Base64 data"] = "Base64 数据",
	["File path"] = "文件路径",
	["Load image"] = "加载图片",
	["Pick a source first."] = "请先选择图片来源。",
	["Loading…"] = "正在加载…",
	["Saved to "] = "已保存到 ",
	["Image opacity"] = "图片不透明度",
	["Dim"] = "背景遮罩",
	["Placement"] = "位置",
	["Preset"] = "预设",
	["Fit"] = "适应",
	["Free lets you anchor, size and rotate it"] = "自由模式可调整锚点、大小和旋转角度",
	["Anchor"] = "锚点",
	["Size"] = "大小",
	["Offset X"] = "水平偏移",
	["Offset Y"] = "垂直偏移",
	["Rotation"] = "旋转",
	["Also behind the toolbar"] = "同时应用到工具栏背景",
	["Not available here"] = "当前环境不可用",
	["This executor is missing writefile or getcustomasset, so background images can't be shown."] = "当前执行器缺少 writefile 或 getcustomasset，无法显示自定义背景图片。",
	["Without image"] = "不包含图片",
	["Your themes"] = "我的主题",
	["Theme name"] = "主题名称",
	["Save as theme"] = "保存为主题",
	["Saved themes"] = "已保存的主题",
	["Delete selected"] = "删除所选项",
	["Include the background image?"] = "是否包含背景图片？",
	["Leave it out"] = "不包含图片",
	["Embed image"] = "嵌入图片",
	["Import code"] = "导入代码",
	["Reset to Graphite with no image. Save to keep it."] = "已重置为石墨主题且不使用图片。点击保存以应用。",
	["Theme saved"] = "主题已保存",
	["No background image"] = "没有背景图片",
	["Reset"] = "重置",
	["Apply"] = "应用",
	["Delete config"] = "删除配置",
	["Confirm"] = "确认",
	["Search"] = "搜索",
	["Refresh"] = "刷新",
	["New"] = "新建",
	["Edit"] = "编辑",
	["Copy"] = "复制",
	["Done"] = "完成",
	["Error"] = "错误",
	["Success"] = "成功",
	["Close window"] = "关闭窗口",
}


local function compileDictionary(dict)
	local exact, patterns, upper = {}, {}, {}
	for key, value in dict do
		if string.find(key, "{%w+}") then
			local names = {}
			local pat = string.gsub(key, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
			pat = string.gsub(pat, "{(%w+)}", function(name)
				table.insert(names, name)
				return "(.-)"
			end)
			table.insert(patterns, { Pattern = "^" .. pat .. "$", Names = names, Value = value })
		else
			exact[key] = value
			upper[string.upper(key)] = string.upper(value)
		end
	end
	return { Exact = exact, Patterns = patterns, Upper = upper }
end

function Hub:T(source: string): string
	local dict = self._dictionary
	if not dict or type(source) ~= "string" or source == "" then return source end
	local hit = dict.Exact[source] or dict.Upper[source]
	if hit then return hit end
	for _, p in dict.Patterns do
		local caps = { string.match(source, p.Pattern) }
		if #caps > 0 then
			local out = p.Value
			for i, name in p.Names do
				-- captured parts may themselves be translatable ("{when}")
				out = string.gsub(out, "{" .. name .. "}", function() return self:T(caps[i]) end)
			end
			return out
		end
	end
	return source
end

function Hub:Languages(): { string }
	local seen, out = { en = true }, { "en" }
	for code in RiftUI.Translations do
		if not seen[code] then seen[code] = true table.insert(out, code) end
	end
	for code in self.Options.Translations or {} do
		if not seen[code] then seen[code] = true table.insert(out, code) end
	end
	table.sort(out, function(a, b) return a == "en" or (b ~= "en" and a < b) end)
	return out
end

local function normalizeLanguage(code)
    if type(code) ~= "string" or code == "" then return "en" end
    local canonical = string.lower(code):gsub("_", "-")
    if canonical == "zh" or canonical:match("^zh%-") then return "zh" end
    return canonical
end

function Hub:SetLanguage(code: string?, quiet: boolean?)
    code = normalizeLanguage(code)
	self.Language = code
	if not quiet then self:_savePref("Language", code) end
	if code == "en" then
		self._dictionary = nil
	else
		local merged = {}
		for k, v in RiftUI.Translations[code] or {} do merged[k] = v end
		for k, v in (self.Options.Translations or {})[code] or {} do merged[k] = v end
		self._dictionary = compileDictionary(merged)
	end
	if self._languageControl then
		self._languageControl:Set(RiftUI.LanguageNames[code] or code, true)
	end
	self:_translateAll()
end

-- Watches every text instance once; the English source is remembered so switching
-- languages back and forth never translates a translation.
function Hub:_watchText(inst: Instance)
	if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end
	local state = self._textSources[inst]
	if state then return end
	state = {}
	self._textSources[inst] = state
	local function apply(prop)
		local current = inst[prop]
		if current ~= state[prop .. "Out"] then
			state[prop] = current
		end
		local out = self:T(state[prop])
		state[prop .. "Out"] = out
		if inst[prop] ~= out then inst[prop] = out end
	end
	state.Apply = function()
		if not inst:IsA("TextBox") then apply("Text") end
		if inst:IsA("TextBox") then apply("PlaceholderText") end
	end
	if not inst:IsA("TextBox") then
		inst:GetPropertyChangedSignal("Text"):Connect(function()
			if self._dictionary or state.TextOut then apply("Text") end
		end)
	else
		inst:GetPropertyChangedSignal("PlaceholderText"):Connect(function()
			if self._dictionary or state.PlaceholderTextOut then apply("PlaceholderText") end
		end)
	end
	state.Apply()
end

function Hub:_translateAll()
	if not self._textSources then
		self._textSources = setmetatable({}, { __mode = "k" })
		self:_connect(self.Gui.DescendantAdded, function(inst)
			if self._dictionary then self:_watchText(inst) end
		end)
	end
	if not self._dictionary and not next(self._textSources) then return end
	for _, inst in self.Gui:GetDescendants() do
		local state = self._textSources[inst]
		if state then state.Apply() elseif self._dictionary then self:_watchText(inst) end
	end
end

---------------------------------------------------------------- child windows
--[[
	A window opens over the hub from a button, a palette entry or code. It holds its own tabs
	and sections, built from the same controls as the panel, so a long feature can move its
	detail out of the main page: Section:Button({ Name = "ESP colours", Window = EspWindow }).
]]
local Window = {}
Window.__index = Window

local WindowTab = setmetatable({}, { __index = Tab })
WindowTab.__index = WindowTab

function WindowTab:Section(options)
	options = type(options) == "table" and table.clone(options) or { Name = tostring(options) }
	-- Windows are modal; pinning a section out of one would strand it on screen.
	options.Pinnable = false
	return Tab.Section(self, options)
end

function Hub:Window(options)
	options = type(options) == "table" and options or { Title = tostring(options) }
	local theme = self.Theme
	local width, height = options.Width or 560, options.Height or 440
	local win = setmetatable({
		Hub = self,
		Title = options.Title or options.Name or "Window",
		Description = options.Description,
		Icon = options.Icon,
		Tabs = {},
		IsOpen = false,
		_internal = options._internal,
	}, Window)
	win.Name = win.Title

	local layer = create("TextButton", {
		Name = "Window_" .. win.Title, Text = "", AutoButtonColor = false,
		BackgroundColor3 = themeColor(theme, "Scrim"), BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 70, Parent = self.Gui,
	})
	local holder = create("Frame", {
		Name = "Holder", BackgroundTransparency = 1, Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(width, height), ZIndex = 71, Parent = layer,
	})
	local grow = create("UIScale", { Scale = 1, Parent = holder })
	shadow(holder, 34, 71, 10)
	local body = create("CanvasGroup", {
		Name = "Body", BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.fromScale(1, 1), GroupTransparency = 1, ZIndex = 72, Parent = holder,
	}, { corner(14) })
	local outline = stroke(themeColor(theme, "PanelStroke"))
	outline.Transparency = 1
	create("Frame", { Name = "Outline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 80, Parent = holder }, { corner(14), outline })
	sheen(body, 16, theme, 79)

	-- header: icon chip, title, description, close
	local chip = create("Frame", { Name = "Chip", BackgroundColor3 = themeColor(theme, "Tile"), Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(32, 32), ZIndex = 73, Parent = body }, { corner(8), stroke(themeColor(theme, "TileStroke")) })
	if not iconLabel(win.Icon, 16, theme.Text, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 74, Parent = chip }) then
		text({ Parent = chip, Text = string.upper(string.sub(win.Title, 1, 1)), FontFace = inter(Enum.FontWeight.SemiBold), Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 74 })
	end
	local hasSub = (win.Description or "") ~= ""
	win._titleLabel = text({ Parent = body, Name = "Title", Text = win.Title, FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 15, Position = UDim2.fromOffset(60, hasSub and 13 or 21), Size = UDim2.new(1, -120, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 73 })
	if hasSub then
		win._descriptionLabel = text({ Parent = body, Name = "Description", Text = win.Description, TextSize = 12, TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(60, 31), Size = UDim2.new(1, -120, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 73 })
	end
	local close = create("TextButton", { Name = "CloseWindow", BackgroundTransparency = 1, Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(44, 44), ZIndex = 74, Parent = body })
	local closeIcon = iconLabel("x", 16, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 75, Parent = close })
	self:_connect(close.MouseEnter, function() if closeIcon then setThemed(closeIcon, "ImageColor3", themeColor(theme, "Text")) end end)
	self:_connect(close.MouseLeave, function() if closeIcon then setThemed(closeIcon, "ImageColor3", themeColor(theme, "SubText")) end end)

	-- tab strip, shown once there are two tabs
	local strip = create("Frame", { Name = "TabStrip", BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 58), Size = UDim2.new(1, -32, 0, 30), Visible = false, ZIndex = 73, Parent = body }, {
		list(Enum.FillDirection.Horizontal, 2, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center),
	})
	local marker = create("Frame", { Name = "TabMarker", BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0, Position = UDim2.fromOffset(16, 89), Size = UDim2.fromOffset(0, 2), ZIndex = 75, Parent = body }, { corner(1) })
	local rule = create("Frame", { Name = "Rule", BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.fromOffset(0, 60), Size = UDim2.new(1, 0, 0, 1), ZIndex = 73, Parent = body })
	local pages = create("Frame", { Name = "Pages", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(0, 61), Size = UDim2.new(1, 0, 1, -61), ZIndex = 73, Parent = body })

	win.Layer, win.Holder, win.Body, win.Pages, win.Strip = layer, holder, body, pages, strip
	win._grow, win._outline, win._marker, win._rule = grow, outline, marker, rule
	win._narrow = false
	fitModal(self, layer, holder, width, height, function(w)
		local narrow = w < 500
		if narrow == win._narrow then return end
		win._narrow = narrow
		for _, tab in win.Tabs do tab:_arrange(narrow) end
	end)
	win._narrow = (holder.AbsoluteSize.X / self._scale) < 500
	self:_connect(close.MouseButton1Click, function() win:Close() end)
	self:_connect(layer.MouseButton1Click, function() win:Close() end)
	self.Windows = self.Windows or {}
	table.insert(self.Windows, win)
	self:_record(self, "Window", options, win)
	return win
end

---------------------------------------------------------------- social buttons
-- Brand colours and marks are the platforms' own; they don't follow the theme.
local SOCIALS = {
	Discord = {
		Label = "Discord",
		Color = Color3.fromRGB(88, 101, 242), -- Blurple, #5865F2
		Hover = Color3.fromRGB(71, 82, 196),
		Asset = "discord-1.png",
		Remote = "assets/brand/discord.png",
		Url = function(value: string): string?
			value = string.gsub(value, "^%s*(.-)%s*$", "%1")
			if string.match(value, "^[%w%-]+$") then return "https://discord.gg/" .. value end
			local code = string.match(value, "^https://discord%.gg/([%w%-]+)/?$")
				or string.match(value, "^https://discord%.com/invite/([%w%-]+)/?$")
				or string.match(value, "^https://discordapp%.com/invite/([%w%-]+)/?$")
			return code and ("https://discord.gg/" .. code) or nil
		end,
	},
}

local function brandMark(platform: string)
	local spec = SOCIALS[platform]
	Assets.brands = Assets.brands or {}
	if Assets.brands[platform] == nil then
		-- a missing brand mark leaves the label alone; it must not switch off every icon
		local failed = Assets.failed
		Assets.brands[platform] = customAsset(spec.Asset, spec.Remote) or false
		Assets.failed = failed
	end
	return Assets.brands[platform] or nil
end

--[[
	A brand-coloured button in the window header that copies an invite link.
		Window:SocialButton({ Discord = "https://discord.gg/your-invite" })
	A bare invite code works too. Narrow windows drop the label and keep the mark.
]]
function Window:SocialButton(options)
	assert(type(options) == "table", "SocialButton expects an options table")
	local platform, raw
	for name in SOCIALS do
		if options[name] ~= nil then
			assert(platform == nil, "SocialButton takes one platform per button")
			platform, raw = name, options[name]
		end
	end
	assert(platform, "SocialButton needs a platform, such as Discord = \"https://discord.gg/...\"")
	local spec = SOCIALS[platform]
	local url = type(raw) == "string" and spec.Url(raw)
	assert(url, platform .. " needs an invite link, such as https://discord.gg/your-invite")
	local hub = self.Hub
	if self._social then self._social:Destroy() end
	local button = create("TextButton", {
		Name = "Social_" .. platform, BackgroundColor3 = spec.Color, Text = "", AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -54, 0, 30), Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X, ZIndex = 74, Parent = self.Body,
	}, { corner(8), padding(0, 10), list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center) })
	local mark = brandMark(platform)
	if mark then
		create("ImageLabel", { Name = "Mark", BackgroundTransparency = 1, Image = mark, ImageColor3 = Color3.new(1, 1, 1), ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromOffset(18, 18), ZIndex = 75, Parent = button })
	end
	local label = text({ Parent = button, Name = "Label", Text = hub:T(options.Label or spec.Label), FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 13, TextColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, ZIndex = 75 })
	create("UISizeConstraint", { MinSize = Vector2.new(34, 30), Parent = button })
	local function fit()
		-- the title gives up the room the button takes; a narrow window keeps only the mark
		label.Visible = not mark or (self.Holder.AbsoluteSize.X / hub._scale) >= 420
		local w = button.AbsoluteSize.X / hub._scale
		for _, l in { self._titleLabel, self._descriptionLabel } do
			if l then l.Size = UDim2.new(1, -120 - math.ceil(w) - 6, l.Size.Y.Scale, l.Size.Y.Offset) end
		end
	end
	local conns = {
		button:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit),
		self.Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit),
		button.MouseEnter:Connect(function() tween(button, FAST, { BackgroundColor3 = spec.Hover }) hub:_showTip(button, url) end),
		button.MouseLeave:Connect(function() tween(button, FAST, { BackgroundColor3 = spec.Color }) if hub._tipFor == button then hub:_hideTip() end end),
		button.MouseButton1Click:Connect(function()
			if typeof(setclipboard) == "function" and pcall(setclipboard, url) then
				hub:Notify({ Title = platform .. " invite copied", Content = "Paste it into your browser or " .. platform .. ".", Icon = "check", Duration = 3 })
			else
				hub:Notify({ Title = platform .. " invite", Content = url, Duration = 8 })
			end
			if type(options.Callback) == "function" then task.spawn(options.Callback, url) end
		end),
	}
	fit()
	local social = { Platform = platform, Url = url, Frame = button, _internal = self._internal }
	function social:SetVisible(v: boolean)
		button.Visible = v
	end
	local window = self
	function social:Destroy()
		for _, c in conns do c:Disconnect() end
		button:Destroy()
		if window._social == social then
			window._social = nil
			for _, l in { window._titleLabel, window._descriptionLabel } do
				if l then l.Size = UDim2.new(1, -120, l.Size.Y.Scale, l.Size.Y.Offset) end
			end
		end
	end
	self._social = social
	hub:_record(self, "SocialButton", options, social)
	return social
end

function Window:_layoutStrip()
	local multi = #self.Tabs > 1
	self.Strip.Visible = multi
	self._marker.Visible = multi
	local top = multi and 92 or 61
	self._rule.Position = UDim2.fromOffset(0, top - 1)
	self.Pages.Position = UDim2.fromOffset(0, top)
	self.Pages.Size = UDim2.new(1, 0, 1, -top)
end

function Window:Tab(options)
	options = type(options) == "table" and options or { Name = tostring(options) }
	local hub, theme = self.Hub, self.Hub.Theme
	local tab = setmetatable({
		Hub = hub,
		Window = self,
		Name = options.Name or "Tab",
		Icon = options.Icon,
		Sections = {},
		_internal = self._internal,
		_recount = function() end,
	}, WindowTab)
	local button = create("TextButton", {
		Name = "WindowTab_" .. tab.Name, BackgroundTransparency = 1, AutoButtonColor = false,
		Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, Text = "",
		LayoutOrder = #self.Tabs + 1, ZIndex = 74, Parent = self.Strip,
	}, { padding(0, 10), list(Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
	local icon = iconLabel(tab.Icon, 14, theme.SubText, { ZIndex = 75, Parent = button })
	local label = text({ Parent = button, Text = tab.Name, TextSize = 13, FontFace = inter(Enum.FontWeight.Medium), TextColor3 = themeColor(theme, "SubText"), Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, ZIndex = 75 })
	tab.Button, tab._label, tab._icon = button, label, icon

	local page = create("Frame", { Name = "WindowPage_" .. tab.Name, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 73, Parent = self.Pages })
	local scroll = create("ScrollingFrame", {
		Name = "Scroll", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"), ScrollBarImageTransparency = 0.4,
		ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 73, Parent = page,
	})
	local columns = create("Frame", { Name = "Columns", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 73, Parent = scroll }, {
		padding(10, 16, 14, 16),
	})
	local flow = list(Enum.FillDirection.Horizontal, 18)
	flow.Parent = columns
	local function column(side)
		return create("Frame", {
			Name = side == 0 and "Left" or "Right", BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -9, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = side, ZIndex = 73, Parent = columns,
		}, { list(Enum.FillDirection.Vertical, 10) })
	end
	tab.Page, tab.Scroll = page, scroll
	tab.Columns = { column(0), column(1), Frame = columns }
	-- Narrow windows stack the right column under the left one.
	function tab:_arrange(narrow)
		flow.FillDirection = narrow and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		flow.Padding = UDim.new(0, narrow and 10 or 18)
		for i = 1, 2 do
			self.Columns[i].Size = narrow and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -9, 0, 0)
		end
	end
	tab:_arrange(self._narrow)

	hub:_connect(button.MouseButton1Click, function() self:SelectTab(tab) end)
	hub:_connect(button.MouseEnter, function()
		if self.Selected ~= tab then setThemed(label, "TextColor3", themeColor(theme, "Text")) end
	end)
	hub:_connect(button.MouseLeave, function()
		if self.Selected ~= tab then setThemed(label, "TextColor3", themeColor(theme, "SubText")) end
	end)
	hub:_connect(button:GetPropertyChangedSignal("AbsoluteSize"), function()
		if self.Selected == tab then self:_moveMarker(false) end
	end)
	table.insert(self.Tabs, tab)
	self:_layoutStrip()
	if not self.Selected then self:SelectTab(tab, true) end
	hub:_record(self, "Tab", options, tab)
	return tab
end

function Window:Section(options)
	if not self._defaultTab then
		self._defaultTab = self:Tab({ Name = "Main" })
	end
	return self._defaultTab:Section(options)
end

function Window:_moveMarker(animate: boolean)
	local tab = self.Selected
	if not tab then return end
	local scale = self.Hub._scale
	local x = (tab.Button.AbsolutePosition.X - self.Body.AbsolutePosition.X) / scale + 10
	local w = math.max(0, tab.Button.AbsoluteSize.X / scale - 20)
	local goal = { Position = UDim2.fromOffset(x, 89), Size = UDim2.fromOffset(w, 2) }
	if animate then
		tween(self._marker, SETTLE, goal)
	else
		self._marker.Position, self._marker.Size = goal.Position, goal.Size
	end
end

function Window:SelectTab(tab, instant: boolean?)
	if type(tab) == "string" then
		for _, t in self.Tabs do
			if t.Name == tab then tab = t break end
		end
	end
	if type(tab) ~= "table" or tab.Window ~= self then return end
	local previous = self.Selected
	if previous == tab then return end
	local theme = self.Hub.Theme
	self.Selected = tab
	local order = table.find(self.Tabs, tab) or 0
	local fromOrder = previous and table.find(self.Tabs, previous) or order
	for _, t in self.Tabs do
		local on = t == tab
		t.Page.Visible = on
		setThemed(t._label, "TextColor3", themeColor(theme, on and "Text" or "SubText"))
		if t._icon then setThemed(t._icon, "ImageColor3", themeColor(theme, on and "Text" or "SubText")) end
	end
	if not instant and self.IsOpen then
		-- the page slides in from the side of the tab it came from
		local dir = order >= fromOrder and 1 or -1
		tab.Page.Position = UDim2.fromOffset(14 * dir, 0)
		tween(tab.Page, SETTLE, { Position = UDim2.new() })
	else
		tab.Page.Position = UDim2.new()
	end
	task.defer(function() self:_moveMarker(not instant and previous ~= nil) end)
end

function Window:Open()
	local hub = self.Hub
	if self.IsOpen or hub._destroyed then return end
	self.IsOpen = true
	hub:_closePopup()
	hub:CloseCommandPalette(true)
	hub:_closeSubTabs()
	hub.Tooltip.Visible = false
	hub._windows = hub._windows or {}
	table.insert(hub._windows, self)
	hub:_overlayRegister("Window", self, {
		Content = self.Holder, Anchor = nil,
		Close = function() self:Close() end, Modal = true,
	})
	self.Layer.Visible = true
	self.Layer.Active = true
	-- reopen on top of anything opened since
	hub._windowZ = (hub._windowZ or 70) + 1
	self.Layer.ZIndex = math.min(hub._windowZ, 79)
	self._grow.Scale = 1
	tween(self.Layer, SOFT, { BackgroundTransparency = 0.45 })
	tween(self.Body, SOFT, { GroupTransparency = 0 })
	tween(self._outline, SOFT, { Transparency = 0 })
	task.defer(function() self:_moveMarker(false) end)
end

function Window:Close()
	local hub = self.Hub
	if not self.IsOpen then return end
	self.IsOpen = false
	hub:_closePopup()
	hub:_overlayUnregister("Window", self)
	local i = hub._windows and table.find(hub._windows, self)
	if i then table.remove(hub._windows, i) end
	if #(hub._windows or {}) == 0 then hub._windowZ = 70 end
	self.Layer.Active = false
	tween(self.Layer, FOLD, { BackgroundTransparency = 1 })
	tween(self._outline, FOLD, { Transparency = 1 })
	self._grow.Scale = 1
	tween(self.Body, FOLD, { GroupTransparency = 1 }).Completed:Connect(function()
		if not self.IsOpen then self.Layer.Visible = false end
	end)
end

function Window:Toggle()
	if self.IsOpen then self:Close() else self:Open() end
end

function Window:Destroy()
	local hub = self.Hub
	self:Close()
	local i = hub.Windows and table.find(hub.Windows, self)
	if i then table.remove(hub.Windows, i) end
	self.Layer:Destroy()
end

---------------------------------------------------------------- command palette
function Hub:SetCommandKey(key)
	if typeof(key) ~= "EnumItem" or key.EnumType ~= Enum.KeyCode or key == Enum.KeyCode.Unknown then return end
	self.CommandKey = key
	if self._commandKeyControl then self._commandKeyControl:Set(key, true) end
	self.SetupData = self.SetupData or {}
	self.SetupData.CommandKey = key.Name
	if hasFS then
		pcall(function()
			ensureFolder(RiftUI.Folder)
			ensureFolder(self:_dir())
			writefile(self:_dir() .. "/setup.json", HttpService:JSONEncode(self.SetupData))
		end)
	end
end

function Hub:CloseCommandPalette(instant)
	local palette = self._palette
	if not palette then return end
	self._palette = nil
	self:_overlayUnregister("CommandPalette", palette)
	palette.Input:ReleaseFocus()
	for _, conn in palette.Connections do conn:Disconnect() end
	if instant or self._destroyed then
		palette.Layer:Destroy()
		return
	end
	-- Fold back toward the search field, faster than it opened.
	palette.Layer.Active = false
	tween(palette.Layer, FOLD, { BackgroundTransparency = 1 })
	tween(palette.Outline, FOLD, { Transparency = 1 })
	palette.Scale.Scale = 1
	tween(palette.Card, FOLD, { GroupTransparency = 1 }).Completed:Connect(function()
		palette.Layer:Destroy()
	end)
end

local CONTROL_ICONS = {
	Toggle = "square-check", Slider = "sliders-horizontal", Dropdown = "list", Input = "text-cursor-input",
	Keybind = "keyboard", ColorPicker = "palette", Button = "mouse-pointer-click", Info = "info",
}

function Hub:_commandEntries()
	local entries = {}
	local function addControls(group, tab, sections, extra)
		for _, section in sections do
			for _, control in section.Controls do
				if not control._hidden and control.Type ~= "Label" and control.Type ~= "Paragraph" then
					local entry = { Name = control.Name, Group = group, Detail = section.Name, Icon = CONTROL_ICONS[control.Type] or "dot", Tab = tab, Control = control, Key = group .. "/" .. section.Name .. "/" .. control.Name }
					for k, v in extra or {} do entry[k] = v end
					table.insert(entries, entry)
				end
			end
		end
	end
	for _, tab in self.Tabs do
		if tab.Tile.Visible then
			table.insert(entries, { Name = tab.Name, Group = "Tabs", Detail = tab.Description, Icon = tab.Icon or "layout-grid", Tab = tab, IsTab = true, Key = "tab/" .. tab.Name })
			addControls(tab.Name, tab, tab.Sections)
			for _, sub in tab.SubTabs or {} do
				table.insert(entries, { Name = sub.Name, Group = tab.Name, Detail = "SubTab", Icon = sub.Icon or "layout-grid", Tab = sub, IsTab = true, Key = "subtab/" .. tab.Name .. "/" .. sub.Name })
				addControls(tab.Name .. " / " .. sub.Name, sub, sub.Sections)
			end
		end
	end
	for _, win in self.Windows or {} do
		if win.Layer.Parent then
			table.insert(entries, { Name = win.Title, Group = "Windows", Detail = win.Description, Icon = win.Icon or "app-window", Window = win, Key = "window/" .. win.Title })
			for _, tab in win.Tabs do
				addControls(win.Title, tab, tab.Sections, { Window = win })
			end
		end
	end
	local function action(name, icon, run)
		table.insert(entries, { Name = name, Group = "Actions", Icon = icon, Run = run, Key = "action/" .. name })
	end
	action(self._visible and "Hide toolbar" or "Show toolbar", "panel-bottom", function() self:ToggleToolbar() end)
	if self._open then action("Close panel", "x", function() self:Close() end) end
	action("Run setup again", "rotate-ccw", function() self:OpenSetup() end)
	return entries
end

function Hub:_rememberJump(key: string)
	local recent = self._recentJumps or {}
	local i = table.find(recent, key)
	if i then table.remove(recent, i) end
	table.insert(recent, 1, key)
	while #recent > 4 do table.remove(recent) end
	self._recentJumps = recent
end

local PALETTE_HEAD, PALETTE_TOP, PALETTE_FOOT = 26, 54, 38

function Hub:OpenCommandPalette()
	if self._destroyed or self._listening then return end
	if self._palette then self:CloseCommandPalette() return end
	self:_closePopup()
	self:_closeSubTabs()
	self.Tooltip.Visible = false
	local theme = self.Theme
	local touch = UserInputService.TouchEnabled
	-- rows are finger-sized on touch screens
	local PALETTE_ROW = touch and 48 or 40
	local layer = create("TextButton", {
		Name = "CommandPalette", Text = "", AutoButtonColor = false,
		BackgroundColor3 = themeColor(theme, "Scrim"), BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), ZIndex = 81, Parent = self.Gui,
	})
	local holder = create("Frame", {
		Name = "CommandWindow", BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(520, 200),
		Active = true, ZIndex = 82, Parent = layer,
	})
	-- Scale from the top edge so the window grows down out of the search field.
	local grow = create("UIScale", { Scale = 1, Parent = holder })
	shadow(holder, 30, 82, 8)
	local win = create("CanvasGroup", {
		Name = "Card", BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.fromScale(1, 1), GroupTransparency = 1, ZIndex = 82, Parent = holder,
	}, { corner(14) })
	local outlineStroke = stroke(themeColor(theme, "PanelStroke"))
	outlineStroke.Transparency = 1
	create("Frame", { Name = "Outline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 86, Parent = holder }, {
		corner(14), outlineStroke,
	})
	iconLabel("search", 16, theme.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(18, PALETTE_TOP / 2), ZIndex = 83, Parent = win })
	local box = create("TextBox", {
		Name = "CommandInput", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(44, 3), Size = UDim2.new(1, -110, 0, PALETTE_TOP - 6),
		Text = "", PlaceholderText = "Search tabs, settings and controls", ClearTextOnFocus = false,
		TextSize = 14, FontFace = inter(Enum.FontWeight.Medium),
		TextColor3 = themeColor(theme, "Text"), PlaceholderColor3 = themeColor(theme, "Muted"),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 83, Parent = win,
	})
	-- Esc on keyboards, an X on touch screens; both close.
	local close = create("TextButton", {
		Name = "CloseCommands", BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0, PALETTE_TOP / 2), Size = UDim2.fromOffset(touch and 44 or 40, 44),
		ZIndex = 83, Parent = win,
	})
	local function keycap(parent, label, props)
		local cap = create("TextLabel", {
			BackgroundColor3 = themeColor(theme, "Field"), Text = label, FontFace = inter(Enum.FontWeight.Medium), TextSize = 10,
			TextColor3 = themeColor(theme, "SubText"), Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 85, Parent = parent,
		}, { corner(4), stroke(themeColor(theme, "FieldStroke")), padding(0, 5) })
		for k, v in props or {} do cap[k] = v end
		return cap
	end
	if touch then
		iconLabel("x", 16, theme.SubText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = close, ZIndex = 84 })
	else
		keycap(close, "Esc", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	end
	create("Frame", { BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.fromOffset(0, PALETTE_TOP), Size = UDim2.new(1, 0, 0, 1), ZIndex = 83, Parent = win })
	local results = create("ScrollingFrame", {
		Name = "CommandResults", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, PALETTE_TOP + 5), Size = UDim2.new(1, -16, 1, -(PALETTE_TOP + 5 + PALETTE_FOOT)),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3, ScrollBarImageColor3 = themeColor(theme, "Knob"),
		ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 83, Parent = win,
	}, { list(Enum.FillDirection.Vertical, 0) })
	local foot = create("Frame", { Name = "CommandFooter", BackgroundColor3 = themeColor(theme, "Section"), BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, PALETTE_FOOT), ZIndex = 83, Parent = win })
	create("Frame", { BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), ZIndex = 84, Parent = foot })
	local status = text({ Name = "CommandStatus", Text = "", TextSize = 11, TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(16, 1), Size = UDim2.new(1, -32, 1, -1), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 84, Parent = foot })
	if not touch then
		local hints = create("Frame", { Name = "KeyHints", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 1), Size = UDim2.new(0, 0, 1, -1), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 84, Parent = foot }, {
			list(Enum.FillDirection.Horizontal, 5, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
		})
		local order = 0
		local function hint(keys, label)
			for _, k in keys do
				order += 1
				keycap(hints, k, { LayoutOrder = order })
			end
			order += 1
			text({ Parent = hints, Text = label, TextSize = 11, TextColor3 = themeColor(theme, "SubText"), Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order, ZIndex = 85 })
			order += 1
			create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(6, 1), LayoutOrder = order, Parent = hints })
		end
		hint({ "↑", "↓" }, "Move")
		hint({ "↵" }, "Open")
		hint({ "Esc" }, "Close")
	end

	local connections = {}
	local palette = { Layer = layer, Input = box, Card = win, Outline = outlineStroke, Scale = grow, Connections = connections, Selected = 1, Matches = {}, Rows = {} }
	self._palette = palette
	self:_overlayRegister("CommandPalette", palette, {
		Content = holder, Close = function() self:CloseCommandPalette() end,
		Modal = true,
	})
	local function connect(signal, fn) table.insert(connections, signal:Connect(fn)) end
	layer.Destroying:Connect(function()
		for _, conn in connections do conn:Disconnect() end
		if self._palette == palette then self._palette = nil end
	end)
	local contentHeight = 0
	local sized = false
	local function fit(animate)
		local vp = viewport() / self._scale
		local top = topInset() / self._scale + 12
		local maxH = math.min(440, vp.Y - top - 16)
		local h = math.min(maxH, PALETTE_TOP + 5 + contentHeight + 6 + PALETTE_FOOT)
		holder.Position = UDim2.new(0.5, 0, 0, top)
		local size = UDim2.fromOffset(math.min(520, vp.X - 24), h)
		-- the card follows its results: fewer matches, shorter box
		if animate and sized then
			tween(holder, SETTLE, { Size = size })
		else
			holder.Size = size
		end
		sized = true
	end
	connect(layer:GetPropertyChangedSignal("AbsoluteSize"), function() fit(false) end)
	connect(self.UIScale:GetPropertyChangedSignal("Scale"), function() fit(false) end)
	local function select(index)
		palette.Selected = math.clamp(index, 1, math.max(1, #palette.Matches))
		for i, row in palette.Rows do
			local goal = i == palette.Selected and 0 or 1
			if row.BackgroundTransparency ~= goal then tween(row, FAST, { BackgroundTransparency = goal }) end
		end
		local row = palette.Rows[palette.Selected]
		if row then
			local y = (row.AbsolutePosition.Y - results.AbsolutePosition.Y) / self._scale + results.CanvasPosition.Y
			local height = results.AbsoluteSize.Y / self._scale
			-- keep a group header in view above the first row of its group
			local above = (palette.HeadAbove[palette.Selected] and PALETTE_HEAD or 0)
			if y - above < results.CanvasPosition.Y then results.CanvasPosition = Vector2.new(0, math.max(0, y - above))
			elseif y + PALETTE_ROW > results.CanvasPosition.Y + height then results.CanvasPosition = Vector2.new(0, y + PALETTE_ROW - height) end
		end
	end
	local function flash(control)
		local mark = stroke(themeColor(self.Theme, "Accent"), 1, 0)
		mark.Parent = control.Frame
		tween(mark, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
		task.delay(1.3, function() mark:Destroy() end)
	end
	local function reveal(scroll, control)
		if control.Section.Pinned then return end
		local y = (control.Frame.AbsolutePosition.Y - scroll.AbsolutePosition.Y) / self._scale + scroll.CanvasPosition.Y
		scroll.CanvasPosition = Vector2.new(0, math.max(0, y - 12))
	end
	local function activate(entry)
		if self._palette ~= palette or not entry then return end
		self:_rememberJump(entry.Key)
		self:CloseCommandPalette()
		if entry.Run then entry.Run() return end
		local control = entry.Control
		local group = control and control.Section
		while group and (group._isGroup or group._isModuleCard) do
			if group._isModuleCard then
				group:SetExpanded(true, true)
			else
				group:SetOpen(true, true)
			end
			group = group.Parent
		end
		if group and group.SetCollapsed then group:SetCollapsed(false, true) end
		if entry.Window then
			local win = entry.Window
			win:Open()
			if entry.Tab then win:SelectTab(entry.Tab, true) end
			if not control then return end
			task.defer(function()
				task.wait()
				if self._destroyed or not control.Frame.Parent then return end
				reveal(entry.Tab.Scroll, control)
				flash(control)
			end)
			return
		end
		self:SetToolbarVisible(true, true)
		self:_applySearch("")
		self.Search.Text = ""
		self:Open(entry.Tab)
		if not control then return end
		task.defer(function()
			if self._destroyed or not control.Frame.Parent then return end
			self:_fitPanel(entry.Tab, false)
			task.wait()
			if self._destroyed or not control.Frame.Parent then return end
			reveal(entry.Tab.Scroll, control)
			flash(control)
		end)
	end
	local function addHeader(label, order)
		create("TextLabel", {
			Name = "CommandGroup", BackgroundTransparency = 1, Text = string.upper(label), TextSize = 10,
			FontFace = inter(Enum.FontWeight.SemiBold), TextColor3 = themeColor(theme, "Muted"),
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -4, 0, PALETTE_HEAD), LayoutOrder = order, ZIndex = 84, Parent = results,
		}, { padding(0, 10, 6, 10) })
		contentHeight += PALETTE_HEAD
	end
	local function addRow(entry, order)
		table.insert(palette.Matches, entry)
		local row = create("TextButton", { Name = "CommandResult", Text = "", AutoButtonColor = false,
			BackgroundColor3 = themeColor(theme, "TileActive"), BackgroundTransparency = 1,
			Size = UDim2.new(1, -4, 0, PALETTE_ROW), LayoutOrder = order, ZIndex = 84, Parent = results,
		}, { corner(8) })
		local icon = iconLabel(entry.Icon, 15, theme.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), ZIndex = 85, Parent = row })
		local left = icon and 38 or 12
		text({ Text = entry.Name, FontFace = inter(Enum.FontWeight.Medium), TextSize = 13,
			TextColor3 = themeColor(theme, "Text"), Position = UDim2.fromOffset(left, 0), Size = UDim2.new(0.62, -left, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 85, Parent = row })
		if entry.Detail and entry.Detail ~= "" then
			text({ Text = entry.Detail, TextSize = 11, TextColor3 = themeColor(theme, "SubText"), TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.new(0.38, -12, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 85, Parent = row })
		end
		local index = #palette.Matches
		row.MouseEnter:Connect(function() if not touch then select(index) end end)
		row.MouseButton1Click:Connect(function() activate(entry) end)
		table.insert(palette.Rows, row)
		contentHeight += PALETTE_ROW
	end
	local function refresh()
		for _, child in results:GetChildren() do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		palette.Rows, palette.Matches, palette.HeadAbove = {}, {}, {}
		contentHeight = 0
		local query = string.lower(string.match(box.Text, "^%s*(.-)%s*$"))
		local entries = self:_commandEntries()
		local groups, order = {}, {}
		local function put(groupName, entry)
			if not groups[groupName] then
				groups[groupName] = {}
				table.insert(order, groupName)
			end
			table.insert(groups[groupName], entry)
		end
		local total = 0
		if query == "" then
			-- nothing typed: recent jumps, then the tabs and actions; controls wait for a query
			local byKey = {}
			for _, e in entries do byKey[e.Key] = e end
			for _, key in self._recentJumps or {} do
				if byKey[key] then put("Recent", byKey[key]) end
			end
			for _, e in entries do
				if (e.IsTab or e.Group == "Windows" or e.Group == "Actions") and not table.find(self._recentJumps or {}, e.Key) then
					put(e.IsTab and "Jump to" or e.Group, e)
				end
			end
		else
			local matches = {}
			for i, entry in entries do
				local name = string.lower(entry.Name)
				-- initials let "fov" find Field of view and "tc" find Team check
				local initials = string.gsub(name, "(%w)%w*%W*", "%1")
				local haystack = name .. " " .. string.lower(self:T(entry.Name)) .. " " .. string.lower(entry.Group) .. " " .. string.lower(entry.Detail or "")
				local matched = initials == query
				if not matched then
					matched = true
					for token in string.gmatch(query, "%S+") do
						if not string.find(haystack, token, 1, true) then matched = false break end
					end
				end
				if matched then
					entry.Score = name == query and 0 or ((string.sub(name, 1, #query) == query or initials == query) and 1 or (string.find(name, query, 1, true) and 2 or 3))
					entry.Order = i
					table.insert(matches, entry)
				end
			end
			-- the best match decides which group is listed first; rows keep their order inside a group
			table.sort(matches, function(a, b) return a.Score < b.Score or (a.Score == b.Score and a.Order < b.Order) end)
			total = #matches
			for i = 1, math.min(40, #matches) do
				put(matches[i].Group, matches[i])
			end
			for _, name in order do
				table.sort(groups[name], function(a, b) return a.Order < b.Order end)
			end
		end
		local n = 0
		for _, groupName in order do
			n += 1
			addHeader(groupName, n)
			palette.HeadAbove[#palette.Matches + 1] = true
			for _, entry in groups[groupName] do
				n += 1
				addRow(entry, n)
			end
		end
		if #palette.Matches == 0 then
			n += 1
			text({ Parent = results, Name = "CommandEmpty", Text = "Nothing matches “" .. box.Text .. "”.\nTry a tab, section or control name.", TextSize = 12, LineHeight = 1.25,
				TextColor3 = themeColor(theme, "SubText"), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, -4, 0, 64), LayoutOrder = n, ZIndex = 84 })
			contentHeight += 64
		end
		results.CanvasPosition = Vector2.zero
		if query == "" then
			status.Text = touch and "Tap a result to jump to it" or "Type to search every control"
		elseif total == 0 then
			status.Text = "No results"
		else
			status.Text = (total > 40 and "First 40 of " .. total or tostring(total)) .. (total == 1 and " result" or " results")
		end
		fit(true)
		select(1)
	end
	connect(box:GetPropertyChangedSignal("Text"), refresh)
	connect(box.FocusLost, function(enter) if enter then activate(palette.Matches[palette.Selected]) end end)
	connect(close.MouseButton1Click, function() self:CloseCommandPalette() end)
	connect(layer.MouseButton1Click, function() self:CloseCommandPalette() end)
	connect(UserInputService.InputBegan, function(input)
		if self._palette ~= palette or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local top = self:_overlayTop()
		if not top or top.Kind ~= "CommandPalette" or top.Owner ~= palette then return end
		-- Escape and the command shortcut belong exclusively to Hub:_bindInput.
		if input.KeyCode == Enum.KeyCode.Down then select(palette.Selected + 1)
		elseif input.KeyCode == Enum.KeyCode.Up then select(palette.Selected - 1)
		elseif input.KeyCode == Enum.KeyCode.Return then activate(palette.Matches[palette.Selected]) end
	end)
	refresh()
	box:CaptureFocus()
	tween(layer, SOFT, { BackgroundTransparency = 0.5 })
	tween(win, SOFT, { GroupTransparency = 0 })
	tween(outlineStroke, SOFT, { Transparency = 0 })
	grow.Scale = 1
end

function Hub:OpenSetup()
	if self._setupOpen then
		return
	end
	self:CloseCommandPalette(true)
	self:_closePopup()
	self:_closeSubTabs()
	-- Setup is exclusive: other modal windows must not remain visible on top.
	while self._windows and #self._windows > 0 do
		self._windows[#self._windows]:Close()
	end
	self._setupOpen = true
	self._listening = true
	self:Close()
	local theme = self.Theme
	local saved = self.SetupData or {}
	local choice = { ToggleKey = self.ToggleKey, Theme = self.ThemeName }
	local devOptions = self:_setupOptions()

	local layer = create("Frame", {
		Name = "Setup",
		BackgroundColor3 = themeColor(theme, "Scrim"),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Active = true,
		ZIndex = 95,
		Parent = self.Gui,
	})
	local holder = create("Frame", {
		Name = "Window",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 16),
		Size = UDim2.fromOffset(500, 440),
		ZIndex = 96,
		Parent = layer,
	})
	self:_overlayRegister("Setup", layer, {
		Content = holder, Modal = true,
		Escape = false, Outside = false,
	})
	self:_connect(layer.Destroying, function()
		self:_overlayUnregister("Setup", layer)
	end)
	shadow(holder, 34, 71, 10)
	task.defer(function() fitModal(self, layer, holder, 500, 440) end)
	local win = create("CanvasGroup", {
		Name = "Body",
		BackgroundColor3 = themeColor(theme, "Panel"),
		Size = UDim2.fromScale(1, 1),
		GroupTransparency = 1,
		ZIndex = 72,
		Parent = holder,
	}, { corner(14) })
	create("Frame", { Name = "Outline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 80, Parent = holder }, { corner(14), stroke(themeColor(theme, "PanelStroke")) })
	sheen(win, 16, theme, 79)

	-- header: progress segments, step label, title, subtitle
	local steps = { "key", "theme" }
	if #devOptions > 0 then
		table.insert(steps, "options")
	end
	table.insert(steps, "compat")
	local progress = create("Frame", { Name = "Progress", BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 22), Size = UDim2.new(1, -48, 0, 2), ZIndex = 73, Parent = win }, {
		list(Enum.FillDirection.Horizontal, 4),
	})
	local segments = {}
	for i = 1, #steps do
		local seg = create("Frame", {
			Name = "Segment",
			BackgroundColor3 = themeColor(theme, "Track"),
			BorderSizePixel = 0,
			Size = UDim2.new(1 / #steps, -4 * (#steps - 1) / #steps, 1, 0),
			LayoutOrder = i,
			ZIndex = 73,
			Parent = progress,
		}, { corner(1) })
		local fill = create("Frame", { Name = "Fill", BackgroundColor3 = themeColor(theme, "Accent"), BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), ZIndex = 74, Parent = seg }, { corner(1) })
		segments[i] = fill
	end
	local stepLabel = text({ Parent = win, Text = "", TextSize = 11, FontFace = inter(Enum.FontWeight.SemiBold), TextColor3 = themeColor(theme, "Muted"), Position = UDim2.fromOffset(24, 38), Size = UDim2.new(1, -48, 0, 14), ZIndex = 73 })
	local title = text({ Parent = win, Text = "", TextSize = 19, FontFace = inter(Enum.FontWeight.SemiBold), Position = UDim2.fromOffset(24, 58), Size = UDim2.new(1, -48, 0, 24), ZIndex = 73 })
	local subtitle = text({
		Parent = win,
		Text = "",
		TextSize = 13,
		TextColor3 = themeColor(theme, "SubText"),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(24, 88),
		Size = UDim2.new(1, -48, 0, 36),
		ZIndex = 73,
	})
	local stage = create("CanvasGroup", {
		Name = "Stage",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(24, 134),
		Size = UDim2.new(1, -48, 1, -134 - 64),
		ZIndex = 73,
		Parent = win,
	})
	create("Frame", { Name = "Rule", BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -64), Size = UDim2.new(1, 0, 0, 1), ZIndex = 73, Parent = win })
	local footer = create("Frame", { Name = "Footer", BackgroundTransparency = 1, Position = UDim2.new(0, 24, 1, -64), Size = UDim2.new(1, -48, 0, 64), ZIndex = 73, Parent = win })
	local skip = create("TextButton", {
		Name = "Skip",
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "Skip setup",
		FontFace = inter(Enum.FontWeight.Medium),
		TextSize = 13,
		TextColor3 = themeColor(theme, "Muted"),
		AutoButtonColor = false,
		ZIndex = 74,
		Parent = footer,
	})
	local buttons = create("Frame", { Name = "Buttons", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(260, 32), ZIndex = 74, Parent = footer }, {
		list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
	})
	local function footerButton(label: string, primary: boolean, order: number)
		local b = create("TextButton", {
			Name = label,
			BackgroundColor3 = primary and themeColor(theme, "Accent") or themeColor(theme, "Tile"),
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = label,
			FontFace = inter(Enum.FontWeight.Medium),
			TextSize = 13,
			TextColor3 = primary and themeColor(theme, "AccentText") or themeColor(theme, "Text"),
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 75,
			Parent = buttons,
		}, { corner(8), padding(0, 16) })
		if not primary then
			stroke(themeColor(theme, "TileStroke")).Parent = b
		end
		return b
	end
	local back = footerButton("Back", false, 1)
	local nextButton = footerButton("Continue", true, 2)
	local conns = {}
	local function on(signal, fn)
		table.insert(conns, signal:Connect(fn))
	end

	-- step bodies
	local step = 0
	local busy = false
	local compatDone = false
	local optionControls = {}
	local pages = {}

	local function page(scrollable)
		if scrollable then
			return create("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 73, Parent = stage })
		end
		return create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 73, Parent = stage })
	end

	-- 1) toolbar key
	do
		local p = page()
		pages.key = { Frame = p, Title = "Toolbar key", Subtitle = "Shows and hides " .. self.Name .. "'s toolbar. You can change it later in Settings." }
		local keyChip = create("TextButton", {
			Name = "Key",
			BackgroundColor3 = themeColor(theme, "Field"),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 34),
			Size = UDim2.fromOffset(200, 64),
			Text = keyName(choice.ToggleKey),
			FontFace = MONO,
			TextSize = 22,
			TextColor3 = themeColor(theme, "Text"),
			AutoButtonColor = false,
			ZIndex = 74,
			Parent = p,
		}, { corner(12) })
		local keyStroke = stroke(themeColor(theme, "FieldStroke"))
		keyStroke.Parent = keyChip
		local hint = text({
			Parent = p,
			Text = "Click, then press a key",
			TextSize = 12,
			TextColor3 = themeColor(theme, "Muted"),
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.fromOffset(0, 110),
			Size = UDim2.new(1, 0, 0, 16),
			ZIndex = 74,
		})
		local listening = false
		on(keyChip.MouseButton1Click, function()
			listening = true
			keyChip.Text = "Press a key…"
			keyChip.TextSize = 16
			tween(keyStroke, FAST, { Color = themeColor(theme, "Accent") })
			hint.Text = "Esc cancels"
		end)
		on(UserInputService.InputBegan, function(input)
			if not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			listening = false
			if input.KeyCode ~= Enum.KeyCode.Escape then
				choice.ToggleKey = input.KeyCode
			end
			keyChip.Text = keyName(choice.ToggleKey)
			keyChip.TextSize = 22
			tween(keyStroke, FAST, { Color = themeColor(theme, "FieldStroke") })
			hint.Text = "Click, then press a key"
		end)
	end

	-- 2) theme cards, each a small picture of the toolbar in that theme
	do
		local p = page(true)
		pages.theme = { Frame = p, Title = "Theme", Subtitle = "Applies immediately. More options in Settings › Theme studio." }
		-- the stage clips (it fades as one), so leave room for the selected card's outline
		padding(3).Parent = p
		create("UIGridLayout", { CellSize = UDim2.new(0.5, -5, 0, 100), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = p })
		local cards = {}
		local function refreshCards()
			for name, c in cards do
				local sel = name == choice.Theme
				tween(c.Stroke, FAST, { Color = sel and c.Colors.Accent or themeColor(theme, "TileStroke"), Thickness = sel and 2 or 1 })
				c.Check.Visible = sel
			end
		end
		for i, preset in THEMES do
			local colors = buildTheme(preset.Name, nil)
			local card = create("TextButton", {
				Name = "Theme_" .. preset.Name,
				BackgroundColor3 = colors.Panel,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = 74,
				Parent = p,
			}, { corner(10) })
			card:SetAttribute("ThemeSwatch", true)
			local cardStroke = stroke(themeColor(theme, "TileStroke"))
			cardStroke.Parent = card
			-- mini toolbar: three tiles, the middle one active with the accent underline
			local mini = create("Frame", {
				Name = "Toolbar",
				BackgroundColor3 = colors.Panel,
				Position = UDim2.fromOffset(12, 12),
				Size = UDim2.fromOffset(86, 30),
				ZIndex = 75,
				Parent = card,
			}, { corner(7), stroke(colors.PanelStroke), padding(4), list(Enum.FillDirection.Horizontal, 3, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center) })
			for t = 1, 3 do
				create("Frame", {
					BackgroundColor3 = t == 2 and colors.TileActive or colors.Tile,
					Size = UDim2.fromOffset(24, 22),
					LayoutOrder = t,
					ZIndex = 76,
					Parent = mini,
				}, { corner(5) })
			end
			create("Frame", { Name = "Accent", BackgroundColor3 = colors.Accent, BorderSizePixel = 0, Position = UDim2.fromOffset(110, 20), Size = UDim2.fromOffset(28, 4), ZIndex = 75, Parent = card }, { corner(2) })
			create("Frame", { Name = "Line", BackgroundColor3 = colors.Divider, BorderSizePixel = 0, Position = UDim2.fromOffset(110, 30), Size = UDim2.new(1, -122, 0, 1), ZIndex = 75, Parent = card })
			text({ Parent = card, Text = preset.Name, FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 14, TextColor3 = colors.Text, Position = UDim2.fromOffset(12, 56), Size = UDim2.new(1, -40, 0, 18), ZIndex = 75 })
			text({ Parent = card, Text = preset.Description, TextSize = 11, TextColor3 = colors.SubText, Position = UDim2.fromOffset(12, 76), Size = UDim2.new(1, -24, 0, 14), ZIndex = 75, TextTruncate = Enum.TextTruncate.AtEnd })
			local check = create("Frame", { Name = "Selected", BackgroundColor3 = colors.Accent, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(16, 16), Visible = false, ZIndex = 76, Parent = card }, { corner(8) })
			iconLabel("check", 11, colors.AccentText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 77, Parent = check })
			cards[preset.Name] = { Stroke = cardStroke, Check = check, Colors = colors }
			on(card.MouseButton1Click, function()
				choice.Theme = preset.Name
				self:_transitionTheme(preset.Name)
				refreshCards()
			end)
		end
		refreshCards()
	end

	-- 3) the hub's own setup options, built with the regular controls
	if #devOptions > 0 then
		local p = page()
		local setupTitle = type(self.Options.Setup) == "table" and self.Options.Setup.Title
		pages.options = { Frame = p, Title = setupTitle or "Hub options", Subtitle = (type(self.Options.Setup) == "table" and self.Options.Setup.Description) or (self.Name .. " asks for a few choices before it starts.") }
		local scroll = create("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = themeColor(theme, "Knob"),
			ZIndex = 74,
			Parent = p,
		})
		local col = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 74, Parent = scroll }, {
			list(Enum.FillDirection.Vertical, 6),
		})
		local fakeTab = setmetatable({
			Hub = self,
			Name = "Setup",
			Sections = {},
			Columns = { col, col, Frame = col },
			_internal = true,
			_recount = function() end,
		}, Tab)
		local section = fakeTab:Section({ Name = self.Name, Pinnable = false })
		for _, opt in devOptions do
			local args = table.clone(opt)
			args.Type = nil
			local current = opt.Flag and RiftUI.Flags[opt.Flag]
			if current and current.Value ~= nil then
				if opt.Type == "Dropdown" and opt.Multi then
					local picked = {}
					for k, v in current.Value do
						if v then
							table.insert(picked, k)
						end
					end
					args.Default = picked
				else
					args.Default = current.Value
				end
			end
			local method = section[opt.Type]
			if method then
				local control = method(section, args)
				control._setup = true
				table.insert(optionControls, control)
			end
		end
	end

	-- 4) compatibility check
	local compat = page()
	pages.compat = { Frame = compat, Title = "Compatibility check", Subtitle = "Calling each executor function RiftUI uses." }
	local compatList = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -78),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = themeColor(theme, "Knob"),
		ZIndex = 74,
		Parent = compat,
	}, { list(Enum.FillDirection.Vertical, 0) })
	local summary = create("Frame", {
		Name = "Summary",
		BackgroundColor3 = themeColor(theme, "Field"),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 1, 1, -14),
		Size = UDim2.new(1, -2, 0, 52),
		Visible = false,
		ZIndex = 74,
		Parent = compat,
	}, { corner(8), padding(0, 12) })
	local summaryStroke = stroke(themeColor(theme, "FieldStroke"))
	summaryStroke.Parent = summary
	local summaryText = text({ Parent = summary, Text = "", TextSize = 12, TextWrapped = true, Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(24, 0), ZIndex = 75 })
	local summaryIcon = create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(16, 16), ZIndex = 75, Parent = summary })

	local STATUS = {
		pass = { Icon = "check", Color = themeColor(theme, "Success") },
		warn = { Icon = "triangle-alert", Color = themeColor(theme, "Warning") },
		fail = { Icon = "circle-x", Color = themeColor(theme, "Danger") },
	}
	local function runCompat()
		compatDone = false
		nextButton.Text = "Checking…"
		compatList:ClearAllChildren()
		list(Enum.FillDirection.Vertical, 0).Parent = compatList
		summary.Visible = false
		local checks = self:_compatChecks()
		local rows = {}
		for i, check in checks do
			local row = create("Frame", { Name = "Check", BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, ZIndex = 74, Parent = compatList })
			local status = create("Frame", { Name = "Status", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(14, 14), ZIndex = 75, Parent = row })
			local dot = create("Frame", { BackgroundColor3 = themeColor(theme, "Muted"), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(5, 5), ZIndex = 76, Parent = status }, { corner(3) })
			local name = text({ Parent = row, Text = check.Name, TextSize = 13, TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(24, 7), Size = UDim2.new(1, -150, 0, 16), ZIndex = 75 })
			text({ Parent = row, Text = check.Detail, FontFace = MONO, TextSize = 11, TextColor3 = themeColor(theme, "Muted"), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 7), Size = UDim2.fromOffset(140, 16), ZIndex = 75 })
			rows[i] = { Row = row, Status = status, Dot = dot, Name = name }
		end
		local results = {}
		local counts = { pass = 0, warn = 0, fail = 0 }
		for i, check in checks do
			local r = rows[i]
			-- the dot grows into a spinner-ish pulse while the check runs
			tween(r.Dot, FAST, { Size = UDim2.fromOffset(9, 9), BackgroundColor3 = themeColor(theme, "Text") })
			task.wait(0.12)
			local ok, err = pcall(check.Run)
			local level = ok and "pass" or check.Severity
			counts[level] += 1
			table.insert(results, { Name = check.Name, Detail = check.Detail, Ok = ok, Severity = check.Severity, Error = not ok and tostring(err) or nil, Impact = check.Impact })
			r.Dot:Destroy()
			local icon = iconLabel(STATUS[level].Icon, 14, STATUS[level].Color, { ZIndex = 76, Parent = r.Status })
			if not icon then
				create("Frame", { BackgroundColor3 = STATUS[level].Color, Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(2, 2), ZIndex = 76, Parent = r.Status }, { corner(5) })
			end
			setThemed(r.Name, "TextColor3", themeColor(theme, "Text"))
			if not ok then
				text({
					Parent = r.Row,
					Text = check.Impact .. "  (" .. string.gsub(tostring(err), "^.-:%d+: ", "") .. ")",
					TextSize = 11,
					TextColor3 = STATUS[level].Color,
					TextWrapped = true,
					Position = UDim2.fromOffset(24, 26),
					Size = UDim2.new(1, -24, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					ZIndex = 75,
				})
				create("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = r.Row })
			end
			if not layer.Parent then
				return
			end
		end
		RiftUI.Compatibility = results
		choice.Compat = results
		local level = counts.fail > 0 and "fail" or counts.warn > 0 and "warn" or "pass"
		summaryIcon:ClearAllChildren()
		iconLabel(STATUS[level].Icon, 16, STATUS[level].Color, { Parent = summaryIcon, ZIndex = 76 })
		setThemed(summaryStroke, "Color", level == "pass" and themeColor(theme, "FieldStroke") or STATUS[level].Color)
		setThemed(summaryText, "TextColor3", level == "pass" and themeColor(theme, "Text") or STATUS[level].Color)
		if level == "pass" then
			summaryText.Text = "All " .. #checks .. " checks passed. Everything RiftUI needs is available."
		else
			summaryText.Text = string.format("%d failed, %d with warnings. You can still finish; the parts listed above won't work in this executor.", counts.fail, counts.warn)
			if counts.fail > 0 then
				recordError(counts.fail .. " compatibility check(s) failed", nil, "setup")
			end
		end
		summary.Visible = true
		compatDone = true
		nextButton.Text = "Finish"
	end

	local function finish(skipped: boolean)
		self:_overlayUnregister("Setup", layer)
		self._setupOpen = false
		task.defer(function()
			self._listening = false
		end)
		for _, c in conns do
			c:Disconnect()
		end
		local data = { Version = RiftUI.Version, Completed = true, Skipped = skipped or nil, Theme = choice.Theme, ToggleKey = choice.ToggleKey.Name, CommandKey = self.CommandKey.Name, Options = {}, Time = os.time(), Studio = (self.SetupData or {}).Studio }
		for _, control in optionControls do
			if control.Flag then
				data.Options[control.Flag] = encodeValue(control)
			end
		end
		if choice.Compat then
			data.Compat = {}
			for _, r in choice.Compat do
				data.Compat[r.Name] = r.Ok and "pass" or r.Severity
			end
		end
		self.SetupData = data
		self.ToggleKey = choice.ToggleKey
		if self._toggleKeyControl then
			self._toggleKeyControl:Set(choice.ToggleKey, true)
		end
		if hasFS then
			pcall(function()
				ensureFolder(RiftUI.Folder)
				ensureFolder(self:_dir())
				writefile(self:_dir() .. "/setup.json", HttpService:JSONEncode(data))
			end)
		end
		tween(layer, FOLD, { BackgroundTransparency = 1 })
		-- Keep the responsive modal position during its fade.
		local tw = tween(win, FOLD, { GroupTransparency = 1 })
		tw.Completed:Wait()
		layer:Destroy()
		self.ThemeName = choice.Theme
		self.Options.ThemeName = choice.Theme
		if self._themeControl then self._themeControl:Set(choice.Theme, true) end
		local target = RiftUI.Hubs[#RiftUI.Hubs] or self
		if not skipped then
			target:Notify({ Title = "Setup complete", Content = UserInputService.TouchEnabled and "Tap Hide toolbar or Show toolbar at the bottom of the screen." or ("Press " .. keyName(choice.ToggleKey) .. " to show or hide the toolbar."), Icon = "circle-check", Duration = 4 })
		end
		local failed = 0
		for _, r in choice.Compat or {} do
			if not r.Ok and r.Severity == "fail" then
				failed += 1
			end
		end
		if failed > 0 then
			target:Notify({ Title = "Some features won't work", Content = failed .. " compatibility check(s) failed. Settings › Run setup again shows which.", Tone = theme.Warning, Icon = "triangle-alert", Duration = 7, Force = true })
		end
	end

	local function show(index: number, dir: number)
		step = index
		local key = steps[index]
		local info = pages[key]
		for i, fill in segments do
			tween(fill, SETTLE, { Size = UDim2.fromScale(i <= index and 1 or 0, 1) })
		end
		stepLabel.Text = string.upper(string.format("Setup · %d of %d", index, #steps))
		title.Text = info.Title
		subtitle.Text = info.Subtitle
		for k, pg in pages do
			pg.Frame.Visible = k == key
		end
		back.Visible = index > 1
		skip.Visible = key ~= "compat"
		nextButton.Text = key == "compat" and (compatDone and "Finish" or "Checking…") or "Continue"
		stage.GroupTransparency = 1
		stage.Position = UDim2.fromOffset(24 + 14 * dir, 134)
		tween(stage, SETTLE, { Position = UDim2.fromOffset(24, 134), GroupTransparency = 0 })
		if key == "compat" and not compatDone then
			task.spawn(runCompat)
		end
	end

	on(nextButton.MouseButton1Click, function()
		if busy then
			return
		end
		if steps[step] == "compat" then
			if compatDone then
				busy = true
				finish(false)
			end
			return
		end
		show(step + 1, 1)
	end)
	on(back.MouseButton1Click, function()
		if step > 1 then
			show(step - 1, -1)
		end
	end)
	on(skip.MouseButton1Click, function()
		if not busy then
			busy = true
			finish(true)
		end
	end)
	on(skip.MouseEnter, function()
		setThemed(skip, "TextColor3", themeColor(theme, "Text"))
	end)
	on(skip.MouseLeave, function()
		setThemed(skip, "TextColor3", themeColor(theme, "Muted"))
	end)
	on(nextButton.MouseEnter, function()
		tween(nextButton, FAST, { BackgroundColor3 = rgb(255, 255, 255):Lerp(theme.Accent, 0.6) })
	end)
	on(nextButton.MouseLeave, function()
		tween(nextButton, FAST, { BackgroundColor3 = themeColor(theme, "Accent") })
	end)

	tween(layer, SOFT, { BackgroundTransparency = 0.5 })
	-- Keep the modal anchored to its available viewport.
	tween(win, SOFT, { GroupTransparency = 0 })
	show(1, 0)
	local _ = saved
end

---------------------------------------------------------------- theme studio & background images
--[[
	Hub:SetBackground({ Url = "...", Base64 = "...", File = "path/in/workspace.png", Opacity = 0.6, Dim = 0.70, Fit = "Crop", Dock = false })
	Hub:SetBackground(nil) removes it.

	Images are saved into RiftUI/<Id>/ with writefile and shown through getcustomasset. Url
	downloads with HttpGet; a URL that returns base64 text (or a data: URI) is decoded too.
]]

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local accentTextFor
local function decodeBase64(data: string): string
	data = string.gsub(data, "^data:[^,]*,", "")
	data = string.gsub(data, "[^%w%+/=]", "")
	local decoder = (typeof(crypt) == "table" and crypt.base64decode) or (typeof(base64_decode) == "function" and base64_decode)
	if decoder then
		local ok, out = pcall(decoder, data)
		if ok and type(out) == "string" then
			return out
		end
	end
	local lookup = {}
	for i = 1, 64 do
		lookup[string.byte(B64, i)] = i - 1
	end
	local n = #data
	local out = buffer.create(n // 4 * 3)
	local o = 0
	for i = 1, n - 3, 4 do
		local a, b, c, d = string.byte(data, i, i + 3)
		local va, vb, vc, vd = lookup[a] or 0, lookup[b] or 0, lookup[c], lookup[d]
		local v = va * 262144 + vb * 4096 + (vc or 0) * 64 + (vd or 0)
		buffer.writeu8(out, o, bit32.extract(v, 16, 8))
		o += 1
		if vc then
			buffer.writeu8(out, o, bit32.extract(v, 8, 8))
			o += 1
		end
		if vd then
			buffer.writeu8(out, o, bit32.extract(v, 0, 8))
			o += 1
		end
	end
	return buffer.readstring(out, 0, o)
end

-- Returns the file extension for image bytes, or nil if they aren't an image.
local function imageKind(bytes: string): string?
	if string.sub(bytes, 1, 8) == "\137PNG\r\n\26\n" then
		return "png"
	elseif string.sub(bytes, 1, 3) == "\255\216\255" then
		return "jpg"
	elseif string.sub(bytes, 1, 4) == "RIFF" and string.sub(bytes, 9, 12) == "WEBP" then
		return "webp"
	elseif string.sub(bytes, 1, 4) == "GIF8" then
		return "gif"
	end
	return nil
end

-- Width and height straight from the file header (PNG, GIF, JPEG, WebP), or nil.
local function imageSize(bytes: string): (number?, number?)
	local function be(i, n)
		local v = 0
		for k = 0, n - 1 do
			v = v * 256 + string.byte(bytes, i + k)
		end
		return v
	end
	local function le(i, n)
		local v = 0
		for k = n - 1, 0, -1 do
			v = v * 256 + string.byte(bytes, i + k)
		end
		return v
	end
	local kind = imageKind(bytes)
	if kind == "png" and #bytes >= 24 then
		return be(17, 4), be(21, 4)
	elseif kind == "gif" and #bytes >= 10 then
		return le(7, 2), le(9, 2)
	elseif kind == "jpg" then
		local i = 3
		while i < #bytes - 9 do
			if string.byte(bytes, i) ~= 0xFF then
				i += 1
				continue
			end
			local marker = string.byte(bytes, i + 1)
			-- SOF0..SOF15 except DHT (C4), JPG (C8) and DAC (CC) carry the frame size
			if marker >= 0xC0 and marker <= 0xCF and marker ~= 0xC4 and marker ~= 0xC8 and marker ~= 0xCC then
				return be(i + 7, 2), be(i + 5, 2)
			end
			i += 2 + be(i + 2, 2)
		end
	elseif kind == "webp" and #bytes >= 30 then
		local chunk = string.sub(bytes, 13, 16)
		if chunk == "VP8X" then
			return le(25, 3) + 1, le(28, 3) + 1
		elseif chunk == "VP8 " then
			return bit32.band(le(27, 2), 0x3FFF), bit32.band(le(29, 2), 0x3FFF)
		elseif chunk == "VP8L" then
			local b = le(22, 4)
			return bit32.band(b, 0x3FFF) + 1, bit32.band(bit32.rshift(b, 14), 0x3FFF) + 1
		end
	end
	return nil, nil
end

-- Resolve a background source to a workspace file path and the image's aspect ratio.
-- Errors carry a readable reason.
function Hub:_storeBackground(source): (string, number)
	if not hasFS then
		error("this executor can't write files, so it can't keep a background", 0)
	end
	if source.File and source.File ~= "" then
		if not isfile(source.File) then
			error("there's no file at " .. source.File, 0)
		end
		local w, h = imageSize(readfile(source.File))
		return source.File, (w and h and h > 0) and w / h or 1
	end
	local bytes
	if source.Base64 and source.Base64 ~= "" then
		bytes = decodeBase64(source.Base64)
	elseif source.Url and source.Url ~= "" then
		local ok, body = pcall(function()
			return game:HttpGet(source.Url)
		end)
		if not ok then
			error("download failed: " .. tostring(body), 0)
		end
		bytes = body
		if #bytes == 0 then
			error("the server returned an empty response; the image file may be empty or unavailable", 0)
		end
		if string.match(string.lower(string.sub(bytes, 1, 200)), "^%s*<") then
			error("the URL returned an HTML page instead of image bytes; use a direct image URL", 0)
		end
		if not imageKind(bytes) and string.match(string.sub(bytes, 1, 200), "^%s*[%w%+/=:;,%-]+") then
			bytes = decodeBase64(bytes)
		end
	else
		error("give a URL, base64 data or a file path", 0)
	end
	local kind = imageKind(bytes)
	if not kind then
		error("that isn't a PNG, JPEG, WebP or GIF image", 0)
	end
	ensureFolder(RiftUI.Folder)
	ensureFolder(self:_dir())
	local path = self:_dir() .. "/background." .. kind
	if source.CacheUnique then
		-- Content-addressed names prevent an incoming URL from overwriting
		-- the image still visible in the outgoing crossfade layer.
		local hash = 5381
		for i = 1, #bytes do
			hash = (hash * 33 + string.byte(bytes, i)) % 2147483647
		end
		path = self:_dir() .. "/background-switch-" .. string.format("%08x", hash) .. "." .. kind
		if type(isfile) == "function" and isfile(path) then
			local ok, existing = pcall(readfile, path)
			if ok and existing == bytes then
				local w, h = imageSize(bytes)
				return path, (w and h and h > 0) and w / h or 1
			end
		end
	end
	writefile(path, bytes)
	local w, h = imageSize(bytes)
	return path, (w and h and h > 0) and w / h or 1
end

local FITS = { Fill = Enum.ScaleType.Crop, Crop = Enum.ScaleType.Crop, Fit = Enum.ScaleType.Fit, Stretch = Enum.ScaleType.Stretch }
local ANCHORS = {
	TopLeft = Vector2.new(0, 0),
	Top = Vector2.new(0.5, 0),
	TopRight = Vector2.new(1, 0),
	Left = Vector2.new(0, 0.5),
	Center = Vector2.new(0.5, 0.5),
	Right = Vector2.new(1, 0.5),
	BottomLeft = Vector2.new(0, 1),
	Bottom = Vector2.new(0.5, 1),
	BottomRight = Vector2.new(1, 1),
}
local ANCHOR_NAMES = { "Top left", "Top", "Top right", "Left", "Center", "Right", "Bottom left", "Bottom", "Bottom right" }
local function anchorKey(name: string?): string
	local key = string.gsub(name or "Center", "%s", "")
	for k in ANCHORS do
		if string.lower(k) == string.lower(key) then
			return k
		end
	end
	return "Center"
end
local function anchorLabel(name: string?): string
	local key = anchorKey(name)
	for _, label in ANCHOR_NAMES do
		if string.gsub(label, "%s", "") == key then
			return label
		end
	end
	return "Center"
end

-- Placement presets for the studio and SetBackground({ Preset = ... })
local PLACEMENTS = {
	Full = { Fit = "Fill", Anchor = "Center", Scale = 1, OffsetX = 0, OffsetY = 0, Rotation = 0 },
	Corner = { Fit = "Free", Anchor = "BottomRight", Scale = 0.75, OffsetX = 0, OffsetY = 0, Rotation = 0 },
	["Body pillow"] = { Fit = "Free", Anchor = "Right", Scale = 1, OffsetX = 0, OffsetY = 0, Rotation = 0 },
	["Body pillow (lying down)"] = { Fit = "Free", Anchor = "Bottom", Scale = 1, OffsetX = 0, OffsetY = 0, Rotation = 90 },
}

--[[
	background = {
		File, Aspect (w/h), Opacity 0..1, Dim 0..1, Dock,
		Fit = "Fill" | "Fit" | "Stretch" | "Free",
		-- Free only:
		Anchor = "TopLeft" … "BottomRight", Scale (image height / panel height),
		OffsetX, OffsetY (px), Rotation (degrees)
	}
]]
local function backgroundLayer(parent: Instance, bg, theme, radius: number, z: number, solid: boolean?)
	-- a CanvasGroup clips the picture to the surface's rounded corners
	local holder = create("CanvasGroup", {
		Name = "Backdrop",
		BackgroundColor3 = themeColor(theme, "Panel"),
		BackgroundTransparency = solid and 0 or 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = z,
		Parent = parent,
	}, { corner(radius) })
	local ok, id
	if bg.Asset and not secureAssets() then
		ok, id = true, bg.Asset
	elseif bg.File and hasAssets then
		ok, id = pcall(getcustomasset, bg.File)
	end
	if ok and id then
		local transparency = 1 - math.clamp(bg.Opacity or 0.6, 0, 1)
		local fit = bg.Fit == "Crop" and "Fill" or (bg.Fit or "Fill")
		if fit == "Free" then
			-- size the box to the rotated picture's bounds so anchoring a corner really hugs the corner
			local a = bg.Aspect or 1
			local rad = math.rad(bg.Rotation or 0)
			local c, s = math.abs(math.cos(rad)), math.abs(math.sin(rad))
			local W, H = a * c + s, a * s + c
			local anchor = ANCHORS[anchorKey(bg.Anchor)]
			local box = create("Frame", {
				Name = "Placement",
				BackgroundTransparency = 1,
				AnchorPoint = anchor,
				Position = UDim2.new(anchor.X, bg.OffsetX or 0, anchor.Y, bg.OffsetY or 0),
				Size = UDim2.fromScale(0, (bg.Scale or 1) * H),
				ZIndex = z,
				Parent = holder,
			}, {
				create("UIAspectRatioConstraint", {
					AspectRatio = W / H,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}),
			})
			create("ImageLabel", {
				Name = "Image",
				BackgroundTransparency = 1,
				Image = id,
				ScaleType = Enum.ScaleType.Stretch,
				ImageTransparency = transparency,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(a / W, 1 / H),
				Rotation = bg.Rotation or 0,
				ZIndex = z,
				Parent = box,
			})
		else
			create("ImageLabel", {
				Name = "Image",
				BackgroundTransparency = 1,
				Image = id,
				ScaleType = FITS[fit] or Enum.ScaleType.Crop,
				ImageTransparency = transparency,
				Size = UDim2.fromScale(1, 1),
				ZIndex = z,
				Parent = holder,
			})
		end
	end
	-- a wash of the panel colour keeps text readable over any picture
	create("Frame", {
		Name = "Dim",
		BackgroundColor3 = themeColor(theme, "Panel"),
		BackgroundTransparency = 1 - math.clamp(bg.Dim ~= nil and bg.Dim or 0.70, 0, 1),
		Size = UDim2.fromScale(1, 1),
		ZIndex = z,
		Parent = holder,
	}, { corner(radius) })
	return holder
end

function Hub:_applyBackground()
	-- Keep image layers separate from every text-bearing GUI object.
	-- Crossfade/Fade/Instant share the same image resolver and lifecycle.
	local previous = self._bgLayers or {}
	for _, stale in self._retiredBgLayers or {} do
		if stale.Parent then cancelMotion(stale); stale:Destroy() end
	end
	self._retiredBgLayers = previous
	self._bgLayers = {}
	self._bgGeneration = (self._bgGeneration or 0) + 1
	local generation = self._bgGeneration
	local mode = self:GetBackgroundTransition()
	local duration = mode == "Instant" and 0 or SOFT.Time
	local bg = self.Background
	self.Dock.BackgroundTransparency = 0
	if bg and (bg.Asset or (bg.File and hasAssets)) and not self.Stealth then
		local panel = backgroundLayer(self.Panel, bg, self.Theme, 14, 0)
		panel.GroupTransparency = mode == "Instant" and 0 or 1
		table.insert(self._bgLayers, panel)
		if bg.Dock then
			self.Dock.BackgroundTransparency = 1
			local dock = backgroundLayer(self.DockHolder, bg, self.Theme, 12, 1, true)
			dock.GroupTransparency = mode == "Instant" and 0 or 1
			table.insert(self._bgLayers, dock)
		end
	end
	local incoming = self._bgLayers
	if mode == "Instant" then
		for _, layer in previous do
			if layer.Parent then cancelMotion(layer); layer:Destroy() end
		end
		self._retiredBgLayers = nil
		return
	end
	-- Serial fade removes old imagery first; crossfade overlaps both layers.
	for _, layer in previous do
		if layer.Parent then tween(layer, SOFT, { GroupTransparency = 1 }) end
	end
	local function reveal()
		if self._destroyed or self._bgGeneration ~= generation then return end
		for _, layer in incoming do
			if layer.Parent then tween(layer, SOFT, { GroupTransparency = 0 }) end
		end
	end
	if mode == "Fade" and #previous > 0 then
		task.delay(duration, reveal)
	else
		reveal()
	end
	local cleanupAfter = mode == "Fade" and duration * 2 or duration
	task.delay(cleanupAfter + 0.05, function()
		for _, layer in previous do
			if layer.Parent then cancelMotion(layer); layer:Destroy() end
		end
		if not self._destroyed and self._bgGeneration == generation then
			self._retiredBgLayers = nil
		end
	end)
end

function Hub:_saveStudio(colors)
	local data = self.SetupData or { Version = RiftUI.Version }
	data.Theme = self.ThemeName
	data.ColorTheme = self.ThemeName
	data.ControlTheme = self:GetControlTheme()
	data.Studio = { Colors = colors, Background = self.Background }
	self.SetupData = data
	if hasFS then
		pcall(function()
			ensureFolder(RiftUI.Folder)
			ensureFolder(self:_dir())
			writefile(self:_dir() .. "/setup.json", HttpService:JSONEncode(data))
		end)
	end
end

local function placement(source, base)
	local preset = source.Preset and PLACEMENTS[source.Preset] or {}
	local function pick(key, default)
		if source[key] ~= nil then
			return source[key]
		elseif preset[key] ~= nil then
			return preset[key]
		elseif base and base[key] ~= nil then
			return base[key]
		end
		return default
	end
	return {
		Fit = pick("Fit", "Fill") == "Crop" and "Fill" or pick("Fit", "Fill"),
		Anchor = anchorKey(pick("Anchor", "Center")),
		Scale = pick("Scale", 1),
		OffsetX = pick("OffsetX", 0),
		OffsetY = pick("OffsetY", 0),
		Rotation = pick("Rotation", 0),
	}
end

function Hub:SetBackground(source)
	if self._destroyed then return false, "hub destroyed" end
	self._backgroundRequest = (self._backgroundRequest or 0) + 1
	local requestId = self._backgroundRequest
	if source == nil or source == false or source == "" or source == "None" then
		self.Background = nil
	else
		if type(source) == "string" or type(source) == "number" then
			local asset, preset = resolveBackgroundPreset(source)
			if not asset then return false, "unknown preset or asset ID" end
			source = { Asset = asset, BackgroundPreset = preset }
		end
		if type(source) ~= "table" then return false, "invalid background" end
		if source.Preset and RiftUI.BackgroundPresets[source.Preset] and not (source.File or source.Url or source.Base64 or source.Asset) then
			source = { Asset = RiftUI.BackgroundPresets[source.Preset], BackgroundPreset = source.Preset,
				Opacity = source.Opacity, Dim = source.Dim, Dock = source.Dock }
		end
		local asset = source.Asset and resolveBackgroundPreset(source.Asset)
		local path, aspect
		if not asset then
			local ok, result, a = pcall(self._storeBackground, self, source)
			if not ok then return false, tostring(result) end
			path, aspect = result, a
		end
		if self._destroyed or self._backgroundRequest ~= requestId then
			return false, "replaced by a newer background"
		end
		if self.Stealth and asset then return false, "image presets are disabled in stealth mode" end
		local bg = placement(source, nil)
		bg.File, bg.Asset = path, asset
		bg.Aspect = aspect or 1
		bg.BackgroundPreset = source.BackgroundPreset
		bg.Url = source.Url
		bg.Opacity = source.Opacity ~= nil and source.Opacity or (1 - (self._backgroundTransparency or .4))
		bg.Dim = source.Dim ~= nil and source.Dim
            or (self.SetupData and self.SetupData.BackgroundDim) or .70
		bg.Dock = source.Dock == true
		self.Background = bg
	end
	self:_applyBackground()
	local studio = self.SetupData and self.SetupData.Studio
	self:_saveStudio(studio and studio.Colors or {})
	return true
end

-- Change the readability wash without reloading or duplicating the image.
-- A background preference can be chosen before the first image is installed.
function Hub:SetBackgroundDim(value: number)
    if self._destroyed then return false, "hub destroyed" end
    local dim = tonumber(value)
    if not dim or dim ~= dim or dim == math.huge or dim == -math.huge then
        return false, "background dim must be a finite number"
    end
    dim = math.clamp(dim, 0, 0.95)
    self.SetupData = self.SetupData or {}
    self.SetupData.BackgroundDim = dim
    if self.Background then self.Background.Dim = dim end
    for _, layer in self._bgLayers or {} do
        local wash = layer:FindFirstChild("Dim")
        if wash then
            tween(wash, FAST, { BackgroundTransparency = 1 - dim })
        end
    end
    if self._backgroundDimControl then
        self._backgroundDimControl:Set(math.floor(dim * 100 + .5), true)
    end
    local studio = self.SetupData.Studio
    self:_saveStudio(studio and studio.Colors or {})
    return true
end

---------------------------------------------------------------- custom themes & share codes
--[[
	A theme ("look") is { Format = "riftui-theme", Version = 1, Name, Base, Colors, Background }.
	Saved themes live in RiftUI/themes/<name>.json and are shared by every hub.
	Share codes are "RIFT1:" .. base64(JSON). A background travels as Image = { Url } or, when the
	author chose to embed it, Image = { Data = base64, Type }. Nothing is downloaded or written
	until the person importing agrees.
]]
local THEME_FORMAT = "riftui-theme"
local SHARE_PREFIX = "RIFT1:"
local MAX_EMBED = 4 * 1024 * 1024

accentTextFor = function(c: Color3): string
	-- dark text on light accents, light text on dark ones
	return (0.299 * c.R + 0.587 * c.G + 0.114 * c.B) > 0.55 and "0F0F11" or "F2F2F3"
end

local function encodeBase64(data: string): string
	local encoder = (typeof(crypt) == "table" and crypt.base64encode) or (typeof(base64_encode) == "function" and base64_encode)
	if encoder then
		local ok, out = pcall(encoder, data)
		if ok and type(out) == "string" then
			return out
		end
	end
	local n = #data
	local out = buffer.create(math.ceil(n / 3) * 4)
	local o = 0
	for i = 1, n, 3 do
		local a, b, c = string.byte(data, i, i + 2)
		local v = a * 65536 + (b or 0) * 256 + (c or 0)
		buffer.writeu8(out, o, string.byte(B64, bit32.extract(v, 18, 6) + 1))
		buffer.writeu8(out, o + 1, string.byte(B64, bit32.extract(v, 12, 6) + 1))
		buffer.writeu8(out, o + 2, b and string.byte(B64, bit32.extract(v, 6, 6) + 1) or 61)
		buffer.writeu8(out, o + 3, c and string.byte(B64, bit32.extract(v, 0, 6) + 1) or 61)
		o += 4
	end
	return buffer.tostring(out)
end

local function themesDir(): string
	return RiftUI.Folder .. "/themes"
end

local function themeFileName(name: string): string
	return (string.gsub(name, "[^%w%s%-_]", ""))
end

-- Checks and normalises a theme table from any source; errors carry a readable reason.
local function validateLook(data)
	if type(data) ~= "table" or data.Format ~= THEME_FORMAT then
		error("that isn't a RiftUI theme", 0)
	end
	local name = type(data.Name) == "string" and themeFileName(data.Name) or ""
	if name == "" then
		error("the theme has no usable name", 0)
	end
	local base = "Graphite"
	for _, t in THEMES do
		if t.Name == data.Base then
			base = t.Name
		end
	end
	local colors = {}
	for k, hex in type(data.Colors) == "table" and data.Colors or {} do
		if type(k) == "string" and DefaultTheme[k] and type(hex) == "string" and pcall(Color3.fromHex, hex) then
			colors[k] = hex
		end
	end
	local bg = nil
	if type(data.Background) == "table" then
		local src = data.Background
		local num = function(v, lo, hi, d)
			return type(v) == "number" and math.clamp(v, lo, hi) or d
		end
		bg = placement(src, nil)
		bg.Scale = num(bg.Scale, 0.05, 3, 1)
		bg.OffsetX = num(bg.OffsetX, -2000, 2000, 0)
		bg.OffsetY = num(bg.OffsetY, -2000, 2000, 0)
		bg.Rotation = num(bg.Rotation, -360, 360, 0)
		bg.Opacity = num(src.Opacity, 0, 1, 0.6)
		bg.Dim = num(src.Dim, 0, 1, 0.70)
		bg.Aspect = num(src.Aspect, 0.05, 20, 1)
		bg.Dock = src.Dock == true
		bg.File = type(src.File) == "string" and src.File or nil
		local image = src.Image
		if type(src.Url) == "string" and string.match(src.Url, "^https?://") then
			bg.Url = src.Url
			image = image or { Url = src.Url }
		end
		if type(image) == "table" then
			if type(image.Url) == "string" and string.match(image.Url, "^https?://") then
				bg.Image = { Url = image.Url }
			elseif type(image.Data) == "string" and #image.Data <= MAX_EMBED * 4 / 3 then
				bg.Image = { Data = image.Data, Type = image.Type }
			end
		end
		if not bg.Image and not bg.File then
			bg = nil
		end
	end
	return { Format = THEME_FORMAT, Version = 1, Name = name, Base = base, Colors = colors, Background = bg }
end

function RiftUI:ListThemes(): { string }
	local out = {}
	if not hasFS or typeof(listfiles) ~= "function" or not isfolder(themesDir()) then
		return out
	end
	for _, path in listfiles(themesDir()) do
		local name = string.match(path, "([^/\\]+)%.json$")
		if name then
			table.insert(out, name)
		end
	end
	table.sort(out)
	return out
end

function Hub:SaveTheme(lookData)
	if not hasFS then
		error("this executor can't write files", 0)
	end
	local data = validateLook(lookData)
	-- keep the local file path so applying it later needs no download
	if data.Background and lookData.Background then
		data.Background.File = lookData.Background.File
	end
	ensureFolder(RiftUI.Folder)
	ensureFolder(themesDir())
	writefile(themesDir() .. "/" .. data.Name .. ".json", HttpService:JSONEncode(data))
	return data
end

function Hub:LoadTheme(name: string)
	local path = themesDir() .. "/" .. themeFileName(name) .. ".json"
	if not hasFS or not isfile(path) then
		error("there's no saved theme called " .. tostring(name), 0)
	end
	local data = validateLook(HttpService:JSONDecode(readfile(path)))
	if data.Background and data.Background.File and not isfile(data.Background.File) then
		data.Background.File = nil
	end
	return data
end

function Hub:DeleteTheme(name: string)
	local path = themesDir() .. "/" .. themeFileName(name) .. ".json"
	if hasFS and typeof(delfile) == "function" and isfile(path) then
		delfile(path)
	end
end

-- A share code for a theme. With embedImage, a local background image travels inside it.
function Hub:ExportTheme(lookData, embedImage: boolean?): string
	local data = validateLook(lookData)
	local bg = data.Background
	if bg then
		local file = lookData.Background and lookData.Background.File
		if bg.Url then
			bg.Image = { Url = bg.Url }
		elseif embedImage and file and hasFS and isfile(file) then
			local bytes = readfile(file)
			if #bytes > MAX_EMBED then
				error("the image is too big to embed (over 4 MB); host it and use a URL instead", 0)
			end
			bg.Image = { Data = encodeBase64(bytes), Type = imageKind(bytes) }
		else
			bg.Image = nil
		end
		bg.File = nil
		if not bg.Image then
			data.Background = nil
		end
	end
	return SHARE_PREFIX .. encodeBase64(HttpService:JSONEncode(data))
end

-- Reads a share code (prefix optional). Doesn't download or write the image; see FetchThemeImage.
function Hub:ImportTheme(code: string)
	code = string.gsub(tostring(code or ""), "%s", "")
	if code == "" then
		error("paste a share code first", 0)
	end
	code = string.gsub(code, "^" .. SHARE_PREFIX, "")
	local ok, data = pcall(function()
		return HttpService:JSONDecode(decodeBase64(code))
	end)
	if not ok then
		error("that code is damaged or incomplete", 0)
	end
	local lookData = validateLook(data)
	if lookData.Background then
		lookData.Background.File = nil
	end
	return lookData
end

-- Downloads (Url) or writes (embedded Data) a theme's image into this hub's folder.
function Hub:FetchThemeImage(lookData): (string, number)
	local bg = lookData.Background
	local image = bg and bg.Image
	if not image then
		error("this theme has no image", 0)
	end
	local path, aspect = self:_storeBackground({ Url = image.Url, Base64 = image.Data })
	bg.File = path
	bg.Aspect = aspect
	bg.Url = image.Url
	return path, aspect
end

-- Move or restyle the current background without loading it again:
-- Hub:PlaceBackground({ Preset = "Body pillow" }) or { Anchor = "TopLeft", Rotation = 90, Scale = 0.6 }
function Hub:PlaceBackground(changes)
	local bg = self.Background
	if not bg then
		return
	end
	local p = placement(changes, bg)
	for k, v in p do
		bg[k] = v
	end
	for _, key in { "Opacity", "Dim", "Dock" } do
		if changes[key] ~= nil then
			bg[key] = changes[key]
		end
	end
	self:_applyBackground()
	local studio = self.SetupData and self.SetupData.Studio
	self:_saveStudio(studio and studio.Colors or {})
end

---------------------------------------------------------------- config sharing and manager
local CONFIG_PREFIX = "RIFTCFG1:"

function Hub:ExportConfig(name: string, options): (string?, string?)
	if not configName(name) then return nil, "invalid config name" end
	local path = self:_configDir() .. "/" .. name .. ".json"
	if not hasFS or not isfile(path) then return nil, "no config named " .. name end
	local ok, value = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok or type(value) ~= "table" then return nil, "config file is damaged" end
	-- Preserve an already encrypted file when sharing, even without its key.
	if value.Format == CONFIG_ENCRYPTED and (not options or options.Encrypt ~= false) then
		return CONFIG_ENCRYPTED_PREFIX .. encodeBase64(HttpService:JSONEncode(value))
	end
	local payload, err = self:_decodeConfig(value, options)
	if not payload then return nil, err end
	payload.Name = name
	if options and options.Encrypt then
		local envelope
		envelope, err = self:_encryptConfig(payload, options)
		if not envelope then return nil, err end
		return CONFIG_ENCRYPTED_PREFIX .. encodeBase64(HttpService:JSONEncode(envelope))
	end
	return CONFIG_PREFIX .. encodeBase64(HttpService:JSONEncode(payload))
end

function Hub:ImportConfig(code: string, saveAs: string?, options): (boolean, string?)
	code = string.gsub(tostring(code or ""), "%s", "")
	if #code > CONFIG_LIMIT * 3 then return false, "config code is too large" end
	local prefix = string.sub(code, 1, #CONFIG_PREFIX)
	if prefix ~= CONFIG_PREFIX and prefix ~= CONFIG_ENCRYPTED_PREFIX then return false, "not a RiftUI config code" end
	local ok, value = pcall(function() return HttpService:JSONDecode(decodeBase64(string.sub(code, #CONFIG_PREFIX + 1))) end)
	if not ok then return false, "the code is cut off or damaged" end
	if prefix == CONFIG_ENCRYPTED_PREFIX and (type(value) ~= "table" or value.Format ~= CONFIG_ENCRYPTED) then return false, "invalid encrypted config code" end
	local payload, err, envelope = self:_decodeConfig(value, options)
	if not payload then return false, err end
	local name = saveAs and saveAs ~= "" and saveAs or payload.Name or "imported"
	if not envelope and self._encryptConfigs then
		envelope, err = self:_encryptConfig(payload, options)
		if not envelope then return false, err end
	end
	return self:_writeConfig(name, payload, envelope)
end

local function ago(t: number?): string
	if type(t) ~= "number" then
		return "saved earlier"
	end
	local d = math.max(0, os.time() - t)
	if d < 60 then
		return "saved just now"
	elseif d < 3600 then
		return "saved " .. math.floor(d / 60) .. " min ago"
	elseif d < 86400 then
		return "saved " .. math.floor(d / 3600) .. " h ago"
	end
	return "saved " .. math.floor(d / 86400) .. " d ago"
end

function Hub:_buildConfigManager()
	local theme = self.Theme
	local win = self:Window({ Title = "Configs", Description = "Save, load and share setups for " .. self.Name, Icon = "folder", Width = 620, Height = 470, _internal = true })
	local function toast(ok, title, detail, err)
		self:Notify(ok and { Title = title, Content = detail, Duration = 3 } or { Title = "Couldn't " .. string.lower(title), Content = err, Tone = self.Theme.Danger })
	end

	local saved = win:Tab({ Name = "Saved", Icon = "folder" })
	local listSection = saved:Section({ Name = "Saved configs", Side = "Left" })
	local holderRow = listSection:_row(0, "ConfigList")
	holderRow.AutomaticSize = Enum.AutomaticSize.Y
	local listFrame = create("Frame", { Name = "Rows", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = holderRow }, {
		list(Enum.FillDirection.Vertical, 4), padding(4, 0, 4, 0),
	})

	local selectedSection = saved:Section({ Name = "Selected", Side = "Right" })
	local selectedName = selectedSection:_info("Config", "None")
	local selected
	selectedSection:Button({ Name = "Load", Callback = function()
		if not selected then return end
		local ok, err = self:LoadConfig(selected)
		toast(ok, "Load", selected, err)
	end })
	selectedSection:Button({ Name = "Save current settings here", Callback = function()
		if not selected then return end
		local ok, err = self:SaveConfig(selected)
		toast(ok, "Save", selected, err)
	end })
	local autoToggle = selectedSection:Toggle({ Name = "Load on start", Description = "Applied when the hub starts", Callback = function(on)
		if not selected then return end
		self:SetAutoload(on and selected or nil)
	end })
	local renameBox = selectedSection:Input({ Name = "Rename to", Placeholder = "New name" })
	selectedSection:Button({ Name = "Rename", Callback = function()
		if not selected then return end
		local to = renameBox.Value
		local ok, err = self:RenameConfig(selected, to)
		if ok then selected = to renameBox:Set("", true) end
		toast(ok, "Rename", tostring(to), err)
	end })
	selectedSection:Button({ Name = "Delete", Danger = true, Callback = function()
		if not selected then return end
		local name = selected
		self:Prompt({
			Title = "Delete " .. name .. "?",
			Content = "The file is removed from RiftUI/" .. self.Id .. "/configs. This can't be undone.",
			Icon = "trash-2",
			Buttons = {
				{ Text = "Cancel" },
				{ Text = "Delete", Primary = true, Callback = function()
					local ok, err = self:DeleteConfig(name)
					if ok and selected == name then selected = nil end
					toast(ok, "Delete", name, err)
				end },
			},
		})
	end })

	local newSection = saved:Section({ Name = "New config", Side = "Right" })
	local newName = newSection:Input({ Name = "Name", Placeholder = "e.g. legit", Default = "" })
	newSection:Button({ Name = "Save current settings", Callback = function()
		local name = newName.Value ~= "" and newName.Value or "default"
		local ok, err = self:SaveConfig(name)
		if ok then selected = name newName:Set("", true) end
		toast(ok, "Save", name, err)
	end })

	if self._configEncryption then
		local storage = saved:Section({ Name = "Storage", Side = "Right" })
		storage:Toggle({ Name = "Encrypt saved configs", Default = self._encryptConfigs, Description = "Uses the key supplied by this hub", Callback = function(on)
			self._encryptConfigs = on
			self:_savePref("EncryptConfigs", on)
		end })
	end
	if self._configServer then
		local remote = win:Tab({ Name = "Remote", Icon = "cloud-download" })
		local source = remote:Section({ Name = "Config server", Side = "Left" })
		local id = source:Input({ Name = "Config ID", Placeholder = "e.g. premium-legit" })
		local cache = source:Toggle({ Name = "Save a local copy", Default = false })
		source:Button({ Name = "Load remote config", Callback = function()
			local ok, err = self:LoadRemoteConfig(id.Value, { SaveAs = cache.Value and id.Value or nil })
			toast(ok, "Load remote config", id.Value, err)
		end })
		source:Paragraph({ Content = "Access is checked by the config server. Remote configs stay in memory unless you save a local copy." })
	end

	local share = win:Tab({ Name = "Share", Icon = "share-2" })
	local export = share:Section({ Name = "Export", Side = "Left" })
	local exportPick = export:Dropdown({ Name = "Config", Options = self:ListConfigs() })
	export:Button({ Name = "Copy share code", Callback = function()
		local name = exportPick.Value
		if not name then
			toast(false, "Copy", nil, "pick a config first")
			return
		end
		local code, err = self:ExportConfig(name)
		if code and typeof(setclipboard) == "function" then
			setclipboard(code)
			toast(true, "Copied", name .. " share code is on your clipboard.")
		else
			toast(false, "Copy", nil, err or "this executor has no clipboard")
		end
	end })
	export:Paragraph({ Title = "What's in a code", Content = "Control values, pins, keys and scale. Codes only import into a hub with the ID " .. self.Id .. "." })
	local import = share:Section({ Name = "Import", Side = "Right" })
	local codeBox = import:Input({ Name = "Share code", Placeholder = CONFIG_PREFIX .. "…" })
	local asBox = import:Input({ Name = "Save as", Placeholder = "Keep original name" })
	import:Button({ Name = "Import", Callback = function()
		local ok, result = self:ImportConfig(codeBox.Value, asBox.Value)
		if ok then
			selected = result
			codeBox:Set("", true)
			asBox:Set("", true)
			win:SelectTab(saved)
		end
		toast(ok, "Import", ok and (result .. " saved. Load it from Saved.") or nil, result)
	end })

	local rows = {}
	local function refresh()
		local names = self:ListConfigs()
		if selected and not table.find(names, selected) then selected = nil end
		local autoload = self:GetAutoload()
		for _, r in rows do r:Destroy() end
		table.clear(rows)
		if #names == 0 then
			table.insert(rows, text({ Parent = listFrame, Text = "No configs yet. Save one under New config.", TextSize = 12, TextColor3 = themeColor(theme, "SubText"), TextWrapped = true, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }))
		end
		for i, name in names do
			local info = self:ConfigInfo(name) or { Name = name }
			local on = name == selected
			local row = create("TextButton", {
				Name = "Config_" .. name, Text = "", AutoButtonColor = false,
				BackgroundColor3 = themeColor(theme, "TileActive"), BackgroundTransparency = on and 0 or 1,
				Size = UDim2.new(1, 0, 0, 44), LayoutOrder = i, Parent = listFrame,
			}, { corner(8) })
			if on then stroke(themeColor(theme, "TileActiveStroke")).Parent = row end
			iconLabel(name == autoload and "zap" or "file", 15, name == autoload and theme.Accent or theme.SubText, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Parent = row })
			text({ Parent = row, Text = name, FontFace = inter(Enum.FontWeight.Medium), TextSize = 13, Position = UDim2.fromOffset(34, 6), Size = UDim2.new(1, -44, 0, 17), TextTruncate = Enum.TextTruncate.AtEnd })
			local meta = info.Encrypted and (info.Locked and "encrypted · key required" or "encrypted") or (info.Damaged and "damaged file" or ((info.Settings or 0) .. " settings · " .. ago(info.SavedAt)))
			if name == autoload then meta ..= " · loads on start" end
			text({ Parent = row, Text = meta, TextSize = 11, TextColor3 = themeColor(theme, info.Damaged and "Danger" or "SubText"), Position = UDim2.fromOffset(34, 23), Size = UDim2.new(1, -44, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd })
			row.MouseEnter:Connect(function() if selected ~= name then tween(row, FAST, { BackgroundTransparency = 0.5 }) end end)
			row.MouseLeave:Connect(function() if selected ~= name then tween(row, FAST, { BackgroundTransparency = 1 }) end end)
			row.MouseButton1Click:Connect(function()
				selected = name
				refresh()
			end)
			table.insert(rows, row)
		end
		selectedName:Set(selected or "None")
		selectedSection.Frame.Visible = selected ~= nil
		autoToggle:Set(selected ~= nil and selected == autoload, true)
		local current = selected or exportPick.Value
		exportPick:SetOptions(names)
		if current and table.find(names, current) then exportPick:Set(current, true) end
	end
	self:_watchConfigs(refresh)
	refresh()
	self.ConfigManager = win
	return win
end

function Hub:OpenThemeStudio()
	if self._studioOpen then
		return
	end
	self._studioOpen = true
	local originalTheme = table.clone(self.Theme)
	local originalName = self.ThemeName
	local theme = self.Theme
	local savedStudio = self.SetupData and self.SetupData.Studio or {}
	local draft = {
		ThemeName = self.ThemeName,
		Accent = theme.Accent,
		Background = self.Background and table.clone(self.Background) or nil,
		Source = "None",
		Opacity = self.Background and self.Background.Opacity or 0.6,
		Dim = self.Background and self.Background.Dim
            or (self.SetupData and self.SetupData.BackgroundDim) or 0.70,
		Dock = self.Background and self.Background.Dock or false,
	}
	for k, v in placement({}, self.Background) do
		draft[k] = v
	end
	local accentChanged = savedStudio.Colors and savedStudio.Colors.Accent ~= nil

	local layer = create("Frame", { Name = "ThemeStudio", BackgroundColor3 = themeColor(theme, "Scrim"), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Active = true, ZIndex = 70, Parent = self.Gui })
	local holder = create("Frame", { Name = "Window", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 16), Size = UDim2.fromOffset(660, 470), ZIndex = 71, Parent = layer })
	shadow(holder, 34, 71, 10)
	local win = create("CanvasGroup", { Name = "Body", BackgroundColor3 = themeColor(theme, "Panel"), Size = UDim2.fromScale(1, 1), GroupTransparency = 1, ZIndex = 72, Parent = holder }, { corner(14) })
	create("Frame", { Name = "Outline", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 80, Parent = holder }, { corner(14), stroke(themeColor(theme, "PanelStroke")) })
	sheen(win, 16, theme, 79)
	text({ Parent = win, Text = "Theme studio", TextSize = 19, FontFace = inter(Enum.FontWeight.SemiBold), Position = UDim2.fromOffset(24, 22), Size = UDim2.new(1, -48, 0, 24), ZIndex = 73 })
	text({ Parent = win, Text = "Colours and background for " .. self.Name .. ". Saved per hub.", TextSize = 13, TextColor3 = themeColor(theme, "SubText"), Position = UDim2.fromOffset(24, 48), Size = UDim2.new(1, -48, 0, 28), TextWrapped = true, ZIndex = 73 })
	create("Frame", { Name = "Rule", BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.fromOffset(0, 80), Size = UDim2.new(1, 0, 0, 1), ZIndex = 73, Parent = win })

	-- left: controls
	local scroll = create("ScrollingFrame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 88),
		Size = UDim2.new(0, 330, 1, -88 - 64),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = themeColor(theme, "Knob"),
		ZIndex = 73,
		Parent = win,
	})
	local col = create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 73, Parent = scroll }, {
		padding(0, 8, 8, 8),
		list(Enum.FillDirection.Vertical, 8),
	})
	local fakeTab = setmetatable({ Hub = self, Name = "Studio", Sections = {}, Columns = { col, col, Frame = col }, _internal = true, _recount = function() end }, Tab)

	-- right: a live miniature of a panel
	local previewHost = create("Frame", { Name = "Preview", BackgroundTransparency = 1, Position = UDim2.new(0, 358, 0, 96), Size = UDim2.new(1, -382, 1, -96 - 80), ZIndex = 73, Parent = win })
	text({ Parent = previewHost, Text = "PREVIEW", TextSize = 11, FontFace = inter(Enum.FontWeight.SemiBold), TextColor3 = themeColor(theme, "Muted"), Size = UDim2.new(1, 0, 0, 14), ZIndex = 74 })
	local status = text({ Parent = previewHost, Text = "", TextSize = 11, TextColor3 = themeColor(theme, "SubText"), TextWrapped = true, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 28), TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 74 })
	fitModal(self, layer, holder, 660, 470, function(w)
		local narrow = w < 580
		previewHost.Visible = not narrow
		scroll.Size = UDim2.new(narrow and 1 or 0, narrow and -32 or 324, 1, narrow and -200 or -168)
		status.Parent = narrow and win or previewHost
		status.Position = narrow and UDim2.new(0, 24, 1, -66) or UDim2.new(0, 0, 1, 0)
		status.Size = narrow and UDim2.new(1, -48, 0, 28) or UDim2.new(1, 0, 0, 28)
	end)
	local miniHolder
	local function drawPreview()
		self:_transitionTheme(draft.ThemeName, { Accent = draft.Accent, AccentText = Color3.fromHex(accentTextFor(draft.Accent)) })
		if miniHolder then
			miniHolder:Destroy()
		end
		local t = buildTheme(draft.ThemeName, { Accent = draft.Accent })
		miniHolder = create("Frame", { Name = "Mini", BackgroundColor3 = t.Panel, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 1, -60), ZIndex = 74, Parent = previewHost }, { corner(12) })
		miniHolder:SetAttribute("ThemeSwatch", true)
		stroke(t.PanelStroke).Parent = miniHolder
		if draft.Background then
			backgroundLayer(miniHolder, {
				File = draft.Background.File,
				Aspect = draft.Background.Aspect,
				Opacity = draft.Opacity,
				Dim = draft.Dim,
				Fit = draft.Fit,
				Anchor = draft.Anchor,
				Scale = draft.Scale,
				-- the preview is about half size, so offsets shrink with it
				OffsetX = draft.OffsetX * 0.5,
				OffsetY = draft.OffsetY * 0.5,
				Rotation = draft.Rotation,
			}, t, 12, 74)
		end
		local content = create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 75, Parent = miniHolder }, { padding(14) })
		local chip = create("Frame", { BackgroundColor3 = t.Tile, Size = UDim2.fromOffset(26, 26), ZIndex = 76, Parent = content }, { corner(7), stroke(t.TileStroke) })
		iconLabel("crosshair", 14, t.Text, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 77, Parent = chip })
		text({ Parent = content, Text = "Combat", FontFace = inter(Enum.FontWeight.SemiBold), TextSize = 13, TextColor3 = t.Text, Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -36, 0, 15), ZIndex = 76 })
		text({ Parent = content, Text = "Aim assist", TextSize = 11, TextColor3 = t.SubText, Position = UDim2.fromOffset(36, 14), Size = UDim2.new(1, -36, 0, 13), ZIndex = 76 })
		text({ Parent = content, Text = "AIM ASSIST", TextSize = 10, FontFace = inter(Enum.FontWeight.SemiBold), TextColor3 = t.SubText, Position = UDim2.fromOffset(0, 44), Size = UDim2.fromOffset(70, 14), ZIndex = 76 })
		create("Frame", { BackgroundColor3 = t.Divider, BorderSizePixel = 0, Position = UDim2.new(0, 72, 0, 51), Size = UDim2.new(1, -72, 0, 1), ZIndex = 76, Parent = content })
		local rows = { { "Enabled", true }, { "Team check", false } }
		for i, r in rows do
			local y = 62 + (i - 1) * 26
			text({ Parent = content, Text = r[1], TextSize = 12, TextColor3 = r[2] and t.Text or t.SubText, Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, -24, 0, 18), ZIndex = 76 })
			local box = create("Frame", { BackgroundColor3 = r[2] and t.Accent or t.Field, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, y + 2), Size = UDim2.fromOffset(14, 14), ZIndex = 76, Parent = content }, { corner(4) })
			stroke(r[2] and t.Accent or t.FieldStroke).Parent = box
			if r[2] then
				iconLabel("check", 10, t.AccentText, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 77, Parent = box })
			end
		end
		text({ Parent = content, Text = "Field of view", TextSize = 12, TextColor3 = t.Text, Position = UDim2.fromOffset(0, 118), Size = UDim2.new(1, -40, 0, 18), ZIndex = 76 })
		text({ Parent = content, Text = "248", FontFace = MONO, TextSize = 11, TextColor3 = t.SubText, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 118), Size = UDim2.fromOffset(40, 18), ZIndex = 76 })
		local track = create("Frame", { BackgroundColor3 = t.Track, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 144), Size = UDim2.new(1, 0, 0, 2), ZIndex = 76, Parent = content })
		create("Frame", { BackgroundColor3 = t.Accent, BorderSizePixel = 0, Size = UDim2.fromScale(0.62, 1), ZIndex = 77, Parent = track })
		create("Frame", { BackgroundColor3 = t.Accent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.62, 0.5), Size = UDim2.fromOffset(4, 12), ZIndex = 78, Parent = track }, { corner(2) })
	end

	-- controls
	local look = fakeTab:Section({ Name = "Look", Pinnable = false })
	local names = {}
	for _, t in THEMES do
		table.insert(names, t.Name)
	end
	local baseControl = look:Dropdown({
		Name = "Base theme",
		Options = names,
		Default = draft.ThemeName,
		Callback = function(v)
			draft.ThemeName = v
			if not accentChanged then
				draft.Accent = buildTheme(v, nil).Accent
			end
			drawPreview()
		end,
	})
	local accentPicker = look:ColorPicker({
		Name = "Accent",
		Default = draft.Accent,
		Callback = function(c)
			draft.Accent = c
			accentChanged = true
			drawPreview()
		end,
	})

	local bgSection = fakeTab:Section({ Name = "Background image", Pinnable = false })
	local sourceInputs = {}
	bgSection:Dropdown({
		Name = "Source",
		Options = { "None", "URL", "Base64", "Workspace file" },
		Default = draft.Background and "Workspace file" or "None",
		Callback = function(v)
			draft.Source = v
			for key, input in sourceInputs do
				input:SetVisible(key == v)
			end
			if v == "None" then
				draft.Background = nil
				status.Text = "No background image."
				drawPreview()
			end
		end,
	})
	sourceInputs.URL = bgSection:Input({ Name = "Image URL", Placeholder = "https://… (.png, .jpg, or base64 text)" })
	sourceInputs.Base64 = bgSection:Input({ Name = "Base64 data", Placeholder = "iVBORw0KGgo… or data:image/png;base64,…" })
	sourceInputs["Workspace file"] = bgSection:Input({ Name = "File path", Placeholder = "e.g. waifu.png", Default = draft.Background and draft.Background.File or "" })
	for key, input in sourceInputs do
		input:SetVisible(draft.Background ~= nil and key == "Workspace file")
	end
	bgSection:Button({
		Name = "Load image",
		Callback = function()
			local src = draft.Source == "None" and (draft.Background and "Workspace file") or draft.Source
			if not src or src == "None" then
				status.Text = "Pick a source first."
				setThemed(status, "TextColor3", themeColor(theme, "Warning"))
				return
			end
			local value = sourceInputs[src].Value
			status.Text = "Loading…"
			setThemed(status, "TextColor3", themeColor(theme, "SubText"))
			local ok, result = pcall(function()
				return self:_storeBackground({
					Url = src == "URL" and value or nil,
					Base64 = src == "Base64" and value or nil,
					File = src == "Workspace file" and value or nil,
				})
			end)
			if ok then
				local _, aspect = self:_storeBackground({ File = result })
				draft.Background = { File = result, Aspect = aspect, Url = src == "URL" and value or nil }
				status.Text = "Saved to " .. result
				setThemed(status, "TextColor3", themeColor(theme, "Success"))
			else
				status.Text = tostring(result)
				setThemed(status, "TextColor3", themeColor(theme, "Danger"))
				recordError("background: " .. tostring(result), nil, "theme studio")
			end
			drawPreview()
		end,
	})
	local opacityControl = bgSection:Slider({ Name = "Image opacity", Min = 0, Max = 100, Step = 5, Default = math.floor(draft.Opacity * 100 + 0.5), Suffix = "%", Callback = function(v)
		draft.Opacity = v / 100
		drawPreview()
	end })
	local dimControl = bgSection:Slider({ Name = "Dim", Min = 0, Max = 95, Step = 5, Default = math.floor(draft.Dim * 100 + 0.5), Suffix = "%", Callback = function(v)
		draft.Dim = v / 100
		drawPreview()
	end })
	-- placement
	local place = fakeTab:Section({ Name = "Placement", Pinnable = false })
	local freeControls = {}
	local function syncFree()
		for _, c in freeControls do
			c:SetVisible(draft.Fit == "Free")
		end
	end
	local presetNames = { "Full", "Corner", "Body pillow", "Body pillow (lying down)" }
	local fitControl, anchorControl, scaleControl, xControl, yControl, rotControl
	place:Dropdown({
		Name = "Preset",
		Options = presetNames,
		Default = nil,
		Callback = function(name)
			local p = PLACEMENTS[name]
			if not p then
				return
			end
			for k, v in p do
				draft[k] = v
			end
			fitControl:Set(draft.Fit, true)
			anchorControl:Set(anchorLabel(draft.Anchor), true)
			scaleControl:Set(math.floor(draft.Scale * 100 + 0.5), true)
			xControl:Set(draft.OffsetX, true)
			yControl:Set(draft.OffsetY, true)
			rotControl:Set(draft.Rotation, true)
			syncFree()
			drawPreview()
		end,
	})
	fitControl = place:Dropdown({
		Name = "Fit",
		Description = "Free lets you anchor, size and rotate it",
		Options = { "Fill", "Fit", "Stretch", "Free" },
		Default = draft.Fit,
		Callback = function(v)
			draft.Fit = v
			syncFree()
			drawPreview()
		end,
	})
	anchorControl = place:Dropdown({
		Name = "Anchor",
		Options = ANCHOR_NAMES,
		Default = anchorLabel(draft.Anchor),
		Callback = function(v)
			draft.Anchor = anchorKey(v)
			drawPreview()
		end,
	})
	scaleControl = place:Slider({ Name = "Size", Min = 10, Max = 200, Step = 5, Default = math.floor(draft.Scale * 100 + 0.5), Suffix = "%", Callback = function(v)
		draft.Scale = v / 100
		drawPreview()
	end })
	xControl = place:Slider({ Name = "Offset X", Min = -300, Max = 300, Step = 2, Default = draft.OffsetX, Suffix = " px", Callback = function(v)
		draft.OffsetX = v
		drawPreview()
	end })
	yControl = place:Slider({ Name = "Offset Y", Min = -300, Max = 300, Step = 2, Default = draft.OffsetY, Suffix = " px", Callback = function(v)
		draft.OffsetY = v
		drawPreview()
	end })
	rotControl = place:Slider({ Name = "Rotation", Min = -180, Max = 180, Step = 15, Default = draft.Rotation, Suffix = "°", Callback = function(v)
		draft.Rotation = v
		drawPreview()
	end })
	freeControls = { anchorControl, scaleControl, xControl, yControl, rotControl }
	syncFree()
	local dockControl = bgSection:Toggle({ Name = "Also behind the toolbar", Default = draft.Dock, Callback = function(v)
		draft.Dock = v
	end })
	if not hasAssets then
		bgSection:Paragraph({ Title = "Not available here", Content = "This executor is missing writefile or getcustomasset, so background images can't be shown." })
	end

	---------------------------------------------------------------- your themes: save, share, import
	local function lookFromDraft(name: string)
		local colors = {}
		if accentChanged then
			colors.Accent = draft.Accent:ToHex()
			colors.AccentText = accentTextFor(draft.Accent)
		end
		local bg
		if draft.Background then
			bg = {
				File = draft.Background.File,
				Aspect = draft.Background.Aspect,
				Url = draft.Background.Url,
				Opacity = draft.Opacity,
				Dim = draft.Dim,
				Fit = draft.Fit,
				Anchor = draft.Anchor,
				Scale = draft.Scale,
				OffsetX = draft.OffsetX,
				OffsetY = draft.OffsetY,
				Rotation = draft.Rotation,
				Dock = draft.Dock,
			}
		end
		return { Format = THEME_FORMAT, Version = 1, Name = name, Base = draft.ThemeName, Colors = colors, Background = bg }
	end
	local function applyLook(lookData)
		draft.ThemeName = lookData.Base
		baseControl:Set(lookData.Base, true)
		local accentHex = lookData.Colors and lookData.Colors.Accent
		if accentHex then
			draft.Accent = Color3.fromHex(accentHex)
			accentChanged = true
		else
			draft.Accent = buildTheme(lookData.Base, nil).Accent
			accentChanged = false
		end
		accentPicker:Set(draft.Accent, true)
		local bg = lookData.Background
		if bg then
			for k, v in placement(bg, nil) do
				draft[k] = v
			end
			draft.Opacity, draft.Dim, draft.Dock = bg.Opacity or 0.6, bg.Dim ~= nil and bg.Dim or 0.70, bg.Dock == true
			draft.Background = bg.File and { File = bg.File, Aspect = bg.Aspect, Url = bg.Url } or nil
		else
			draft.Background = nil
			for k, v in PLACEMENTS.Full do
				draft[k] = v
			end
		end
		fitControl:Set(draft.Fit, true)
		anchorControl:Set(anchorLabel(draft.Anchor), true)
		scaleControl:Set(math.floor(draft.Scale * 100 + 0.5), true)
		xControl:Set(draft.OffsetX, true)
		yControl:Set(draft.OffsetY, true)
		rotControl:Set(draft.Rotation, true)
		opacityControl:Set(math.floor(draft.Opacity * 100 + 0.5), true)
		dimControl:Set(math.floor(draft.Dim * 100 + 0.5), true)
		dockControl:Set(draft.Dock, true)
		syncFree()
		drawPreview()
	end
	local function say(msg: string, tone)
		status.Text = msg
		setThemed(status, "TextColor3", tone or themeColor(theme, "SubText"))
	end
	-- ask before downloading or writing an image that came with a theme, then apply it
	local function offerImage(lookData)
		local image = lookData.Background and lookData.Background.Image
		if not image or (lookData.Background.File and isfile(lookData.Background.File)) then
			applyLook(lookData)
			say("Applied " .. lookData.Name .. ". Save to keep it.", theme.Success)
			return
		end
		local isUrl = image.Url ~= nil
		local host = isUrl and (string.match(image.Url, "^https?://([^/]+)") or image.Url) or nil
		self:Prompt({
			Icon = "image-down",
			Title = isUrl and "Download this theme's image?" or "Save this theme's image?",
			Content = isUrl and ("“" .. lookData.Name .. "” uses a background image from " .. host .. ". RiftUI only downloads it if you say so.")
				or ("“" .. lookData.Name .. "” carries its own background image (" .. math.ceil(#image.Data * 3 / 4 / 1024) .. " KB). It gets written to your workspace."),
			Buttons = {
				{
					Text = "Without image",
					Callback = function()
						lookData.Background = nil
						applyLook(lookData)
						say("Applied " .. lookData.Name .. " without its image.", theme.SubText)
					end,
				},
				{
					Text = isUrl and "Download" or "Save image",
					Primary = true,
					Callback = function()
						say("Fetching image…")
						local ok, path, aspect = pcall(self.FetchThemeImage, self, lookData)
						if ok then
							applyLook(lookData)
							pcall(self.SaveTheme, self, lookData)
							say("Applied " .. lookData.Name .. " with its image (" .. path .. "). Save to keep it.", theme.Success)
						else
							say("Couldn't get the image: " .. tostring(path), theme.Danger)
							recordError("theme image: " .. tostring(path), nil, "theme studio")
						end
						local _ = aspect
					end,
				},
			},
		})
	end

	local mine = fakeTab:Section({ Name = "Your themes", Pinnable = false })
	local nameBox = mine:Input({ Name = "Theme name", Placeholder = "e.g. Midnight Sakura" })
	local savedPick
	local function refreshSaved()
		savedPick:SetOptions(RiftUI:ListThemes())
	end
	mine:Button({
		Name = "Save as theme",
		Callback = function()
			local name = nameBox.Value
			local ok, err = pcall(self.SaveTheme, self, lookFromDraft(name))
			if ok then
				refreshSaved()
				say("Saved “" .. name .. "” to " .. RiftUI.Folder .. "/themes.", theme.Success)
			else
				say(tostring(err), theme.Danger)
			end
		end,
	})
	savedPick = mine:Dropdown({
		Name = "Saved themes",
		Options = RiftUI:ListThemes(),
		Default = nil,
		Callback = function(name)
			local ok, data = pcall(self.LoadTheme, self, name)
			if ok then
				nameBox:Set(name, true)
				offerImage(data)
			else
				say(tostring(data), theme.Danger)
			end
		end,
	})
	mine:Button({
		Name = "Delete selected",
		Danger = true,
		Callback = function()
			if savedPick.Value then
				self:DeleteTheme(savedPick.Value)
				say("Deleted “" .. savedPick.Value .. "”.")
				savedPick:Set(nil, true)
				refreshSaved()
			end
		end,
	})

	local share = fakeTab:Section({ Name = "Share", Pinnable = false })
	local codeBox = share:Input({ Name = "Share code", Placeholder = "RIFT1:… paste a code here to import it" })
	local function export(embed: boolean)
		local name = nameBox.Value ~= "" and nameBox.Value or (draft.ThemeName .. " remix")
		local ok, code = pcall(self.ExportTheme, self, lookFromDraft(name), embed)
		if not ok then
			say(tostring(code), theme.Danger)
			return
		end
		codeBox:Set(code, true)
		local copied = typeof(setclipboard) == "function" and pcall(setclipboard, code)
		say(string.format("%s code for “%s” (%d characters).", copied and "Copied the" or "Here's the", name, #code), theme.Success)
	end
	share:Button({
		Name = "Copy share code",
		Callback = function()
			local bg = draft.Background
			if bg and not bg.Url then
				-- the image only exists in this workspace: embed it, or share the look without it
				local size = 0
				pcall(function()
					size = #readfile(bg.File)
				end)
				self:Prompt({
					Icon = "image",
					Title = "Include the background image?",
					Content = "This image isn't from a URL, so other people can only get it if it's embedded in the code (+" .. math.ceil(size * 4 / 3 / 1024) .. " KB of text).",
					Buttons = {
						{ Text = "Leave it out", Callback = function()
							export(false)
						end },
						{ Text = "Embed image", Primary = true, Callback = function()
							export(true)
						end },
					},
				})
			else
				export(false)
			end
		end,
	})
	share:Button({
		Name = "Import code",
		Callback = function()
			local ok, data = pcall(self.ImportTheme, self, codeBox.Value)
			if not ok then
				say(tostring(data), theme.Danger)
				return
			end
			pcall(self.SaveTheme, self, data)
			refreshSaved()
			nameBox:Set(data.Name, true)
			offerImage(data)
		end,
	})

	-- footer
	create("Frame", { Name = "Rule", BackgroundColor3 = themeColor(theme, "Divider"), BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -64), Size = UDim2.new(1, 0, 0, 1), ZIndex = 73, Parent = win })
	local footer = create("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 24, 1, -64), Size = UDim2.new(1, -48, 0, 64), ZIndex = 73, Parent = win }, {
		list(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center),
	})
	local function close()
		self._studioOpen = false
		tween(layer, FOLD, { BackgroundTransparency = 1 })
		-- Keep the responsive modal position during its fade.
		tween(win, FOLD, { GroupTransparency = 1 }).Completed:Wait()
		layer:Destroy()
	end
	local function button(label: string, primary: boolean, order: number, fn)
		local b = create("TextButton", {
			BackgroundColor3 = primary and themeColor(theme, "Accent") or themeColor(theme, "Tile"),
			Size = UDim2.fromOffset(0, 32),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = label,
			FontFace = inter(Enum.FontWeight.Medium),
			TextSize = 13,
			TextColor3 = primary and themeColor(theme, "AccentText") or themeColor(theme, "Text"),
			AutoButtonColor = false,
			LayoutOrder = order,
			ZIndex = 74,
			Parent = footer,
		}, { corner(8), padding(0, 16) })
		if not primary then
			stroke(themeColor(theme, "TileStroke")).Parent = b
		end
		b.MouseButton1Click:Connect(fn)
	end
	button("Reset", false, 1, function()
		draft.ThemeName = "Graphite"
		draft.Accent = DefaultTheme.Accent
		draft.Background = nil
		for k, v in PLACEMENTS.Full do
			draft[k] = v
		end
		fitControl:Set("Fill", true)
		syncFree()
		accentChanged = false
		accentPicker:Set(DefaultTheme.Accent, true)
		status.Text = "Reset to Graphite with no image. Save to keep it."
		setThemed(status, "TextColor3", themeColor(theme, "SubText"))
		drawPreview()
	end)
	button("Cancel", false, 2, function()
		self:_transitionTheme(originalName, originalTheme)
		close()
	end)
	button("Save", true, 3, function()
		local colors = {}
		if accentChanged then
			colors.Accent = draft.Accent:ToHex()
			colors.AccentText = accentTextFor(draft.Accent)
		end
		self.Background = draft.Background and {
			File = draft.Background.File,
			Aspect = draft.Background.Aspect or 1,
			Url = draft.Background.Url,
			Opacity = draft.Opacity,
			Dim = draft.Dim,
			Fit = draft.Fit,
			Anchor = draft.Anchor,
			Scale = draft.Scale,
			OffsetX = draft.OffsetX,
			OffsetY = draft.OffsetY,
			Rotation = draft.Rotation,
			Dock = draft.Dock,
		} or nil
		self.ThemeName = draft.ThemeName
		self.Options.ThemeName = draft.ThemeName
		if self._themeControl then self._themeControl:Set(draft.ThemeName, true) end
		if self._activeThemeInfo then self._activeThemeInfo:Set(draft.ThemeName) end
		self:_saveStudio(colors)
		self:_applyBackground()
		close()
		local hub = RiftUI.Hubs[#RiftUI.Hubs]
		if hub then
			hub:Notify({ Title = "Theme saved", Content = draft.ThemeName .. (draft.Background and " with a background image" or ""), Icon = "palette", Duration = 3 })
		end
	end)

	tween(layer, SOFT, { BackgroundTransparency = 0.5 })
	-- Keep the modal anchored to its available viewport.
	tween(win, SOFT, { GroupTransparency = 0 })
	status.Text = draft.Background and ("Current image: " .. draft.Background.File) or "No background image."
	drawPreview()
end

---------------------------------------------------------------- built-in settings tab
function Hub:_buildSettings()
	task.defer(function()
		if self._destroyed then
			return
		end
		local tab = self:Tab({ Name = "Settings", Icon = "settings", Description = "Toolbar, configs and about", _internal = true, _order = 1000, Group = "Settings" })
		self.SettingsTab = tab

		local ui = tab:Section({ Name = "Interface", Side = "Left" })
		local key = ui:Keybind({
			Name = "Toolbar key",
			Default = self.ToggleKey,
			Mode = "None", -- the hub itself listens for the toolbar key
			ChangedCallback = function(k)
				if k then
					self.ToggleKey = k
				end
			end,
		})
		self._toggleKeyControl = key
		self._commandKeyControl = ui:Keybind({
			Name = "Command palette key", Default = self.CommandKey, Mode = "None",
			ChangedCallback = function(k)
				if k then self:SetCommandKey(k) end
				self._commandKeyControl:Set(self.CommandKey, true)
			end,
		})
		self._scaleControl = ui:Slider({
			Name = "Interface scale",
			Min = 70,
			Max = 140,
			Step = 5,
			Default = math.floor(self._scale * 100 + 0.5),
			Suffix = "%",
			Callback = function(v)
				self:SetScale(v / 100)
			end,
		})
		local themeNames = {}
		for _, t in THEMES do
			table.insert(themeNames, t.Name)
		end
		self._themeControl = ui:Dropdown({
			Name = "Color theme",
			Options = themeNames,
			Default = self.ThemeName,
			Callback = function(name)
				if name ~= self.ThemeName then
					self:SetColorTheme(name)
				end
			end,
		})
		self._activeThemeInfo = ui:_info("Current theme", self.ThemeName)
		self._controlThemeControl = ui:Dropdown({
			Name = "Control theme",
			Options = { "Default", "Rounded" },
			Default = self:GetControlTheme(),
			Callback = function(name)
				self:SetControlTheme(name)
			end,
		})
		local feedback = tab:Section({ Name = "Interaction feedback", Side = "Left" })
		local sound = self:GetUISounds()
		feedback:Toggle({
			Name = "UI sounds", Description = "Subtle interface sound feedback",
			Default = sound.Enabled,
			Callback = function(on)
				self:SetUISounds({ Enabled = on })
				self:_savePref("UISounds", self:GetUISounds())
			end,
		})
		feedback:Dropdown({
			Name = "UI sound preset", Options = { "Soft", "Minimal" },
			Default = sound.Preset,
			Callback = function(name)
				self:SetUISounds({ Preset = name })
				self:_savePref("UISounds", self:GetUISounds())
				self:PlayUISound("Select")
			end,
		})
		feedback:Slider({
			Name = "UI sound volume", Min = 0, Max = 100, Step = 5,
			Default = math.floor(sound.Volume * 100),
			Suffix = "%",
			Callback = function(v)
				self:SetUISounds({ Volume = v / 100 })
				self:_savePref("UISounds", self:GetUISounds())
			end,
		})
		local appearance = tab:Section({ Name = "Background appearance", Side = "Left" })
		local backgrounds = { "None" }
		for _, name in RiftUI.BackgroundPresetOrder do table.insert(backgrounds, name) end
		appearance:Dropdown({
			Name = "UI background", Options = backgrounds,
			Default = self.Background and self.Background.BackgroundPreset or "None",
			Callback = function(name)
				local ok, err = self:SetBackgroundPreset(name)
				if not ok then self:Notify({ Title = "Background unavailable", Content = err, Duration = 4 }) end
			end,
		})
		appearance:Slider({
			Name = "UI background opacity", Min = 0, Max = 100, Step = 5,
			Default = math.floor((self.Background and self.Background.Opacity or .6) * 100),
			Suffix = "%",
			Callback = function(v) self:SetBackgroundTransparency(1 - v / 100) end,
		})
		self._backgroundDimControl = appearance:Slider({
            Name = "Background readability", Min = 0, Max = 95, Step = 5,
            Default = math.floor((self.Background and self.Background.Dim
                or (self.SetupData and self.SetupData.BackgroundDim) or .70) * 100 + .5),
            Suffix = "%",
            Callback = function(v) self:SetBackgroundDim(v / 100) end,
        })
		appearance:Button({
			Name = "Open theme studio",
			Callback = function()
				self:Close()
				self:OpenThemeStudio()
			end,
		})
		if self._stealthLocked then
			self._stealthStatus = ui:_info("Stealth mode", self.Stealth and "Script: On" or "Script: Off")
			ui:Paragraph({ Content = "Stealth mode is controlled by this script." })
		else
			self._stealthControl = ui:Toggle({
				Name = "Stealth mode",
				Description = "Local assets only, built-in font fallback, quiet library output",
				Default = self.Stealth,
				Callback = function(on) self:SetStealth(on) end,
			})
		end
		self._watermarkControl = ui:Toggle({
			Name = "Watermark",
			Description = "Hub name, FPS, ping and time",
			Default = self._watermark ~= nil,
			Callback = function(on) self:SetWatermark(on) end,
		})
		self._keylistControl = ui:Toggle({
			Name = "Keybind list",
			Description = "Bound keys and their state",
			Default = self._keylist ~= nil,
			Callback = function(on) self:SetKeybindList(on) end,
		})
		local languageNames, codeFor = {}, {}
		for _, code in self:Languages() do
			local label = RiftUI.LanguageNames[code] or code
			table.insert(languageNames, label)
			codeFor[label] = code
		end
		if #languageNames > 1 then
			self._languageControl = ui:Dropdown({
				Name = "Language",
				Options = languageNames,
				Default = RiftUI.LanguageNames[self.Language or "en"] or self.Language or "English",
				Callback = function(label) self:SetLanguage(codeFor[label] or "en") end,
			})
		end

		if next(self._requirements) then
			local section = tab:Section({ Name = "Feature requirements", Side = "Right" })
			local fields = {}
			local ids = {}
			for id in self._requirements do table.insert(ids, id) end
			table.sort(ids)
			for _, id in ids do fields[id] = section:_info(self._requirements[id].Name, "Checking…") end
			local function refresh(results)
				for id, field in fields do
					local result = results[id]
					field:Set(result.Passed and "Available" or result.Status == "pending" and "Checking…" or "Unavailable")
				end
			end
			self:OnRequirementsChanged(refresh)
			refresh(self._requirementResults)
			section:Button({ Name = "Recheck feature requirements", Callback = function() self:RunRequirements() end })
		end

		local switching = tab:Section({ Name = "Weather effects", Side = "Right" })
		switching:Dropdown({
			Name = "Weather effect",
			Options = self:ListWeather(),
			Default = self:GetWeather(),
			Callback = function(kind)
				local ok, err = self:SetWeather(kind)
				if not ok then self:Notify({ Title = "Weather unavailable", Content = tostring(err) }) end
			end,
		})
		switching:Dropdown({
			Name = "Weather area",
			Options = { "Screen", "UI" },
			Default = self:GetWeatherMode(),
			Callback = function(mode) self:SetWeatherMode(mode) end,
		})
		switching:Slider({
			Name = "Weather density", Min = 0, Max = 200, Step = 10,
			Default = math.floor(self:GetWeatherDensity() * 100 + .5), Suffix = "%",
			Callback = function(v) self:SetWeatherDensity(v / 100) end,
		})
		switching:Slider({
			Name = "Weather speed", Min = 25, Max = 250, Step = 5,
			Default = math.floor(self:GetWeatherSpeed() * 100 + .5), Suffix = "%",
			Callback = function(v) self:SetWeatherSpeed(v / 100) end,
		})
		switching:Slider({
			Name = "Weather opacity", Min = 5, Max = 100, Step = 5,
			Default = math.floor(self:GetWeatherOpacity() * 100 + .5), Suffix = "%",
			Callback = function(v) self:SetWeatherOpacity(v / 100) end,
		})

		local cfg = tab:Section({ Name = "Config", Side = "Right" })
		local nameBox = cfg:Input({ Name = "Config name", Placeholder = "e.g. legit", Default = "default" })
		cfg:Button({
			Name = "Save",
			Callback = function()
				local ok, err = self:SaveConfig(nameBox.Value)
				self:Notify(ok and { Title = "Config saved", Content = nameBox.Value, Duration = 3 } or { Title = "Couldn't save", Content = err, Tone = self.Theme.Danger })
			end,
		})
		local pick = cfg:Dropdown({ Name = "Saved", Options = self:ListConfigs(), Default = nil })
		cfg:Button({
			Name = "Load selected",
			Callback = function()
				local name = pick.Value or nameBox.Value
				local ok, err = self:LoadConfig(name)
				self:Notify(ok and { Title = "Config loaded", Content = tostring(name), Duration = 3 } or { Title = "Couldn't load", Content = err, Tone = self.Theme.Danger })
			end,
		})
		-- autoload has its own picker, so browsing Saved never changes what loads on start
		local autoToggle = cfg:Toggle({
			Name = "Autoload a config",
			Description = "Loads on start, before the toolbar shows",
			Default = self:GetAutoload() ~= nil,
		})
		local autoPick = cfg:Dropdown({
			Name = "Autoload config",
			Options = self:ListConfigs(),
			Default = self:GetAutoload(),
		})
		-- Default-on controls can emit during construction. Bind cross-control callbacks
		-- only after both controls exist; their initial state is synchronized below.
		autoToggle.Callback = function(on)
			autoPick:SetVisible(on)
			if not on then
				self:SetAutoload(nil)
			elseif autoPick.Value then
				self:SetAutoload(autoPick.Value)
			end
		end
		autoPick.Callback = function(name)
			if autoToggle.Value and name then
				self:SetAutoload(name)
				self:Notify({ Title = "Autoload set", Content = tostring(name) .. " loads when the hub starts.", Duration = 3 })
			end
		end
		autoPick:SetVisible(autoToggle.Value)
		local manager = self:_buildConfigManager()
		cfg:Button({ Name = "Manage configs", Window = manager })
		self:_watchConfigs(function()
			local names = self:ListConfigs()
			local current = pick.Value
			pick:SetOptions(names)
			if current and table.find(names, current) then pick:Set(current, true) end
			local auto = self:GetAutoload()
			autoPick:SetOptions(names)
			if auto then autoPick:Set(auto, true) end
			-- an autoload cleared elsewhere (deleted config) turns the toggle off; picking one turns it on
			if (auto ~= nil) ~= autoToggle.Value and (auto ~= nil or autoPick.Value == nil or not table.find(names, autoPick.Value)) then
				autoToggle:Set(auto ~= nil, true)
				autoPick:SetVisible(auto ~= nil)
			end
		end)

		local about = tab:Section({ Name = "About", Side = "Left" })
		about:Paragraph({ Content = "This script is powered by RiftUI. Licensed under MPL-2.0" })
		about:Button({ Name = "Copy GitHub link", Description = "github.com/Naymmmm/riftui", Callback = function()
			if typeof(setclipboard) == "function" then
				setclipboard("https://github.com/Naymmmm/riftui")
				self:Notify({ Title = "Link copied", Content = "github.com/Naymmmm/riftui", Icon = "check", Duration = 2 })
			else
				self:Notify({ Title = "GitHub", Content = "https://github.com/Naymmmm/riftui", Duration = 6 })
			end
		end })
		-- Developer Mode hides behind six taps on the version, like Android's build number
		local taps, lastTap = 0, 0
		local versionRow
		versionRow = about:_info("Version", RiftUI.Version, function()
			if RiftUI.DeveloperMode then
				self:Notify({ Title = "Developer Mode is on", Content = "Find it in the Developer tab.", Icon = "bug", Duration = 2, Force = true })
				self:Open(self.DeveloperTab)
				return
			end
			local now = os.clock()
			taps = (now - lastTap < 1.5) and taps + 1 or 1
			lastTap = now
			if taps < 6 then
				if taps >= 3 then
					-- count down in place of the version, then quietly put it back
					local left = 6 - taps
					versionRow:Set(left .. (left == 1 and " tap left" or " taps left"))
					task.delay(1.5, function()
						if os.clock() - lastTap >= 1.45 then
							versionRow:Set(RiftUI.Version)
						end
					end)
				end
				return
			end
			taps = 0
			versionRow:Set(RiftUI.Version)
			self:Prompt({
				Icon = "bug",
				Title = "Enable Developer Mode?",
				Content = "Adds a Developer tab with the hub's state machine, every captured error and tools like Reinitialize. It's meant for hub authors and stays on until you turn it off.",
				Buttons = {
					{ Text = "Cancel" },
					{
						Text = "Enable",
						Primary = true,
						Callback = function()
							RiftUI:SetDeveloperMode(true)
							task.wait(0.15)
							self:Open(self.DeveloperTab)
						end,
					},
				},
			})
		end)
		local executor = typeof(identifyexecutor) == "function" and select(1, identifyexecutor()) or "Unknown"
		about:_info("Executor", tostring(executor))
		about:_info("Hub ID", self.Id)
		about:Button({
			Name = "Run setup again",
			Callback = function()
				self:Close()
				self:OpenSetup()
			end,
		})
		about:Button({
			Name = "Unload hub",
			Danger = true,
			Callback = function()
				self:Destroy()
			end,
		})
	end)
end

---------------------------------------------------------------- reinitialize & teardown
function Hub:_teardown()
	if self._destroyed then return end
	for _, control in self._treeControls or {} do
		if control.FlushState then control:FlushState() end
	end
	self._destroyed = true
	self:_overlayClear()
	self:_clearDataLinks()
	Motion.cancelAll(self)
	for binding in self._activeDrags or {} do binding:Cancel() end
	self._activeDrags = nil
	self._capturedDrag = nil
	self._skinEntries = nil
	self:_disposeDesignTokens()
	self:_disposeWeather()
	cancelHubCallbacks(self)
	for _, tw in self._themeTweens or {} do tw:Cancel() end
	self:_releaseOwned()
	cancelHubMotion(self.Gui)
	self._themeTweens = nil
	secureHubs[self] = nil
	for _, thread in self._requirementThreads or {} do pcall(task.cancel, thread) end
	self._requirementWatchers = {}
	if self._watermark then
		for _, conn in self._watermark.Conns do conn:Disconnect() end
	end
	self:CloseCommandPalette(true)
	self:_closePopup()
	for _, c in self._conns do
		c:Disconnect()
	end
	if self._stealthConn then
		self._stealthConn:Disconnect()
	end
	for _, tab in self.Tabs do
		if tab._stateConn then
			tab._stateConn:Disconnect()
		end
		local groups = { tab }
		for _, sub in tab.SubTabs or {} do table.insert(groups, sub) end
		for _, page in groups do
			for _, section in page.Sections do
				for _, c in section._pinConns or {} do c:Disconnect() end
				for _, control in section.Controls do
					if control.Flag and RiftUI.Flags[control.Flag] == control then
						RiftUI.Flags[control.Flag] = nil
					end
				end
			end
		end
	end
	self.Gui:Destroy()
	local i = table.find(RiftUI.Hubs, self)
	if i then
		table.remove(RiftUI.Hubs, i)
	end
end

--[[
	Rebuilds the hub from the calls that created it, keeps every flag's value and pin, and
	turns the old Hub/Tab/Section/control tables into forwarders so references the hub
	script still holds keep working.
]]
function Hub:Reinitialize()
	setState("Reinitializing", self.Name)
	local quiet = self._quietReinit
	self._quietReinit = nil
	local values = self:_flagValues()
	local treeStates = self:_treeStateSnapshot()
	local designTokens = self:GetDesignTokenOverrides()
	-- Preserve dynamically updated widget state, not just initial creation args.
	local liveInfoStates = {}
	for _, step in self._recipe or {} do
		local control = step.Result
		if type(control) == "table" and not control._disposed then
			if (control.Type == "InfoGrid" or control.Type == "InfoList")
				and type(control.Get) == "function" then
				liveInfoStates[control] = { Kind = "Info", Items = control:Get() }
			elseif control.Type == "ModuleCard" then
				liveInfoStates[control] = { Kind = "Module", Status = control:GetStatus(),
					Summary = control:GetSummary(), Locked = control._locked,
					Favorite = control:IsFavorite(), Expanded = control:GetExpandedPreference() }
			end
		end
	end
	local savedDataLinks = {}
	for link in self._dataLinks or {} do
		if link.Connected then
			table.insert(savedDataLinks, { Old = link, Source = link.Source,
				Target = link.Target, Options = table.clone(link.Options or {}),
				Stats = link:GetStats() })
		end
	end
	local pins = table.clone(self.Pins)
	local recipe = self._recipe
	local stealth = self.Stealth
	local scale = self._scale
	local toggleKey = self.ToggleKey
	local commandKey = self.CommandKey
	local configEncryption, encryptConfigs, configServer = self._configEncryption, self._encryptConfigs, self._configServer
	local wasOpen = self._open and self._open.Name
	local wasSubTab = self._open and self._open.ActiveSubTab and self._open.ActiveSubTab.Name
	self:_teardown()
	if failureGui then
		failureGui:Destroy()
		failureGui = nil
	end
	local ok, err = xpcall(function()
		local rebuildOptions = table.clone(self.Options)
		rebuildOptions.ControlTheme = self:GetControlTheme()
		rebuildOptions.DesignTokens = designTokens
		rebuildOptions.ColorTheme = self:GetColorTheme()
		rebuildOptions.Stealth = stealth
		rebuildOptions.Loading = nil
		local fresh = RiftUI:CreateHub(rebuildOptions)
		fresh._stealthLocked = self._stealthLocked
		fresh._replaying = true
		fresh.ToggleKey = toggleKey
		fresh.CommandKey = commandKey
		fresh._configEncryption, fresh._encryptConfigs, fresh._configServer = configEncryption, encryptConfigs, configServer
		fresh:SetScale(scale)
		-- When Reinitialize is called through an older forwarded Hub handle,
		-- replay targets belong to the live Hub, not the original alias.
		local map = { [self] = fresh }
		map[canonicalRecipeObject(self)] = fresh
		local function resolveRecipe(value)
			local current = value
			for _ = 1, 16 do
				local matched = map[current]
				if matched then return matched end
				local nextObject = canonicalRecipeObject(current)
				if nextObject == current then break end
				current = nextObject
			end
			return nil
		end
		for _, step in recipe do
			local target = resolveRecipe(step.Target)
			if target then
				map[step.Result] = target[step.Method](target, step.Args)
			end
		end
		-- Restore data before wiring event links, avoiding unintended replay.
		for oldControl, state in liveInfoStates do
			local updated = map[oldControl]
			if updated then
				if state.Kind == "Info" then
					updated:Set(state.Items, true)
				else
					updated:SetStatus(state.Status.Status, state.Status.Tone)
					updated:SetSummary(state.Summary)
					updated:SetLocked(state.Locked)
					updated:SetFavorite(state.Favorite)
					updated:SetExpanded(state.Expanded, true)
				end
			end
		end
		fresh._replaying = false
		fresh:_restoreTreeStates(treeStates)
		local rebuilt = {}
		for _, step in recipe do
			table.insert(rebuilt, {
				Target = map[step.Target] or step.Target,
				Method = step.Method,
				Args = step.Args,
				Result = map[step.Result] or step.Result,
			})
		end
		fresh._recipe = rebuilt
		for _, linkState in savedDataLinks do
			local source = resolveRecipe(linkState.Source)
			local target = resolveRecipe(linkState.Target)
			if source and target then
				local options = table.clone(linkState.Options)
				options.Immediate = false -- replay saved state, not intermediate callbacks
				local link = fresh:LinkData(source, target, options)
				local stats = linkState.Stats or {}
				for _, key in { "Delivered", "Skipped", "Errors", "Cycles", "Overflow" } do
					link[key] = stats[key] or 0
				end
				link.LastError = stats.LastError
				map[linkState.Old] = link
			end
		end
		for flag, saved in values do
			local control = RiftUI.Flags[flag]
			if control then
				if #control.Requires > 0 and not control:IsAvailable() then
					control._requirementRestore = saved
				else pcall(decodeValue, control, saved, true) end
			end
		end
		for _, tab in fresh.Tabs do
			local pages = { tab }
			for _, sub in tab.SubTabs or {} do table.insert(pages, sub) end
			for _, page in pages do
				page:_recount()
				for _, section in page.Sections do
					if pins[section.Id] then section:Pin(pins[section.Id]) end
				end
			end
		end
		if stealth then
			fresh:SetStealth(true)
		end
		for old, new in map do
			if old ~= new then
				table.clear(old)
				setmetatable(old, { __index = new, __newindex = new })
			end
		end
		if not quiet then
			fresh:Notify({ Title = "Hub reinitialized", Content = #recipe .. " elements rebuilt, values kept.", Duration = 3 })
		end
		if wasOpen then
			task.wait(0.1)
			fresh:Open(wasOpen)
			if wasSubTab and fresh._open then
				for _, sub in fresh._open.SubTabs or {} do
					if sub.Name == wasSubTab then fresh:_setSubTab(fresh._open, sub); break end
				end
			end
		end
	end, debug.traceback)
	if not ok then
		recordError(tostring(err), nil, "reinitialize")
		setState("Failed", "reinitialize")
		task.defer(showFailure, tostring(err), nil)
	end
end

function Hub:Destroy()
	self:_teardown()
	setState("Unloaded", self.Name)
end

return RiftUI
