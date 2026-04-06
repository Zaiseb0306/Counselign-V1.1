════════ Exception caught by rendering library ═════════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 11 pixels on the bottom.

The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16

: To inspect this widget in Flutter DevTools, visit: http://127.0.0.1:9100/#/inspector?uri=http%3A%2F%2F127.0.0.1%3A51799%2Fj3bcUp25EtY%3D%2F&inspectorRef=inspector-0

The overflowing RenderFlex has an orientation of Axis.vertical.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be seen. If the content is legitimately bigger than the available space, consider clipping it with a ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex, like a ListView.
The specific RenderFlex in question is: RenderFlex#37c30 OVERFLOWING
    parentData: offset=Offset(16.0, 16.0) (can use size)
    constraints: BoxConstraints(w=294.0, h=251.2)
    size: Size(294.0, 251.2)
    direction: vertical
    mainAxisAlignment: start
    mainAxisSize: min
    crossAxisAlignment: start
    textDirection: ltr
    verticalDirection: down
    spacing: 0.0
    child 1: RenderFlex#3fbb6 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 22.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: center
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderDecoratedBox#26e77 relayoutBoundary=up2
            parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(65.2, 22.0)
            decoration: BoxDecoration
                color: Color(alpha: 0.1020, red: 0.2980, green: 0.6863, blue: 0.3137, colorSpace: ColorSpace.sRGB)
                borderRadius: BorderRadius.circular(4.0)
            configuration: ImageConfiguration(bundle: PlatformAssetBundle#911f2(), devicePixelRatio: 3.0, locale: en_US, textDirection: TextDirection.ltr, platform: android)
            child: RenderPadding#34f76 relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(65.2, 22.0)
                padding: EdgeInsets(8.0, 4.0, 8.0, 4.0)
                textDirection: ltr
                child: RenderParagraph#4480e relayoutBoundary=up4
                    parentData: offset=Offset(8.0, 4.0) (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(49.2, 14.0)
                    textAlign: start
                    textDirection: ltr
                    softWrap: wrapping at box width
                    overflow: clip
                    textScaler: SystemTextScaler (0.84997x)
                    locale: en_US
                    maxLines: unlimited
        child 2: RenderConstrainedBox#a2525 relayoutBoundary=up2
            parentData: offset=Offset(65.2, 11.0); flex=1; fit=FlexFit.tight (can use size)
            constraints: BoxConstraints(w=180.3, 0.0<=h<=Infinity)
            size: Size(180.3, 0.0)
            additionalConstraints: BoxConstraints(w=0.0, h=0.0)
        child 3: RenderParagraph#4eecd relayoutBoundary=up2
            parentData: offset=Offset(245.5, 3.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(48.5, 16.0)
            textAlign: start
            textDirection: ltr
            softWrap: wrapping at box width
            overflow: clip
            textScaler: SystemTextScaler (0.84997x)
            locale: en_US
            maxLines: unlimited
            text: TextSpan
                debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
                inherit: false
                color: Color(alpha: 1.0000, red: 0.4588, green: 0.4588, blue: 0.4588, colorSpace: ColorSpace.sRGB)
                family: Inter
                size: 12.0
                weight: 400
                letterSpacing: 0.0
                baseline: alphabetic
                height: 1.6x
                leadingDistribution: even
                decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
                "1/12/2025"
    child 2: RenderConstrainedBox#98286 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 22.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 8.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=8.0)
    child 3: RenderFlex#83abd relayoutBoundary=up1
        parentData: offset=Offset(0.0, 30.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 22.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: center
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderDecoratedBox#29243 relayoutBoundary=up2
            parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(83.1, 22.0)
            decoration: BoxDecoration
                borderRadius: BorderRadius.circular(12.0)
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(alpha: 1.0000, red: 0.2549, green: 0.4118, blue: 0.8824, colorSpace: ColorSpace.sRGB), Color(alpha: 1.0000, red: 0.5294, green: 0.8078, blue: 0.9804, colorSpace: ColorSpace.sRGB)], tileMode: TileMode.clamp)
            configuration: ImageConfiguration(bundle: PlatformAssetBundle#911f2(), devicePixelRatio: 3.0, locale: en_US, textDirection: TextDirection.ltr, platform: android)
            child: RenderPadding#65766 relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(83.1, 22.0)
                padding: EdgeInsets(8.0, 4.0, 8.0, 4.0)
                textDirection: ltr
                child: RenderFlex#c709d relayoutBoundary=up4
                    parentData: offset=Offset(8.0, 4.0) (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(67.1, 14.0)
                    direction: horizontal
                    mainAxisAlignment: start
                    mainAxisSize: min
                    crossAxisAlignment: center
                    textDirection: ltr
                    verticalDirection: down
                    spacing: 0.0
    child 4: RenderConstrainedBox#016f7 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 52.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 12.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=12.0)
    child 5: RenderParagraph#8929f relayoutBoundary=up1
        parentData: offset=Offset(0.0, 64.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(240.6, 22.0)
        textAlign: start
        textDirection: ltr
        softWrap: wrapping at box width
        overflow: clip
        textScaler: SystemTextScaler (0.84997x)
        locale: en_US
        maxLines: unlimited
        text: TextSpan
            debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
            inherit: false
            color: Color(alpha: 1.0000, red: 0.0980, green: 0.0980, blue: 0.4392, colorSpace: ColorSpace.sRGB)
            family: Inter
            size: 16.0
            weight: 700
            letterSpacing: 0.0
            baseline: alphabetic
            height: 1.6x
            leadingDistribution: even
            decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
            "Phenylpropanolamine, Chlorphenamine"
    child 6: RenderConstrainedBox#dead8 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 86.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 4.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=4.0)
    child 7: RenderParagraph#fd9b0 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 90.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(71.7, 16.0)
        textAlign: start
        textDirection: ltr
        softWrap: wrapping at box width
        overflow: clip
        textScaler: SystemTextScaler (0.84997x)
        locale: en_US
        maxLines: unlimited
        text: TextSpan
            debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
            inherit: false
            color: Color(alpha: 1.0000, red: 0.4588, green: 0.4588, blue: 0.4588, colorSpace: ColorSpace.sRGB)
            family: Inter
            size: 12.0
            weight: 400
            letterSpacing: 0.0
            baseline: alphabetic
            height: 1.6x
            leadingDistribution: even
            decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
            "ID: 2020123456"
    child 8: RenderConstrainedBox#e0944 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 106.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 8.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=8.0)
    child 9: RenderFlex#72237 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 114.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 16.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: center
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderSemanticsAnnotations#271f9 relayoutBoundary=up2
            parentData: offset=Offset(0.0, 1.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(14.0, 14.0)
            child: RenderExcludeSemantics#3f830 relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(14.0, 14.0)
                excluding: true
                child: RenderConstrainedBox#0fd92 relayoutBoundary=up4
                    parentData: <none> (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(14.0, 14.0)
                    additionalConstraints: BoxConstraints(w=14.0, h=14.0)
        child 2: RenderConstrainedBox#24ac7 relayoutBoundary=up2
            parentData: offset=Offset(14.0, 8.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(4.0, 0.0)
            additionalConstraints: BoxConstraints(w=4.0, 0.0<=h<=Infinity)
        child 3: RenderParagraph#7615b relayoutBoundary=up2
            parentData: offset=Offset(18.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(82.9, 16.0)
            textAlign: start
            textDirection: ltr
            softWrap: wrapping at box width
            overflow: clip
            textScaler: SystemTextScaler (0.84997x)
            locale: en_US
            maxLines: unlimited
            text: TextSpan
                debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
                inherit: false
                color: Color(alpha: 1.0000, red: 0.4588, green: 0.4588, blue: 0.4588, colorSpace: ColorSpace.sRGB)
                family: Inter
                size: 12.0
                weight: 400
                letterSpacing: 0.0
                baseline: alphabetic
                height: 1.6x
                leadingDistribution: even
                decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
                "3:30 PM - 4:00 PM"
    child 10: RenderConstrainedBox#98207 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 130.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 4.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=4.0)
    child 11: RenderFlex#83a2e relayoutBoundary=up1
        parentData: offset=Offset(0.0, 134.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 16.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: center
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderSemanticsAnnotations#058bb relayoutBoundary=up2
            parentData: offset=Offset(0.0, 1.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(14.0, 14.0)
            child: RenderExcludeSemantics#e72dd relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(14.0, 14.0)
                excluding: true
                child: RenderConstrainedBox#bb4c8 relayoutBoundary=up4
                    parentData: <none> (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(14.0, 14.0)
                    additionalConstraints: BoxConstraints(w=14.0, h=14.0)
        child 2: RenderConstrainedBox#967f4 relayoutBoundary=up2
            parentData: offset=Offset(14.0, 8.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(4.0, 0.0)
            additionalConstraints: BoxConstraints(w=4.0, 0.0<=h<=Infinity)
        child 3: RenderParagraph#5f6c4 relayoutBoundary=up2
            parentData: offset=Offset(18.0, 0.0); flex=1; fit=FlexFit.tight (can use size)
            constraints: BoxConstraints(w=276.0, 0.0<=h<=Infinity)
            size: Size(276.0, 16.0)
            textAlign: start
            textDirection: ltr
            softWrap: wrapping at box width
            overflow: ellipsis
            textScaler: SystemTextScaler (0.84997x)
            locale: en_US
            maxLines: unlimited
            text: TextSpan
                debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
                inherit: false
                color: Color(alpha: 1.0000, red: 0.4588, green: 0.4588, blue: 0.4588, colorSpace: ColorSpace.sRGB)
                family: Inter
                size: 12.0
                weight: 400
                letterSpacing: 0.0
                baseline: alphabetic
                height: 1.6x
                leadingDistribution: even
                decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
                "In-person"
    child 12: RenderConstrainedBox#52cdc relayoutBoundary=up1
        parentData: offset=Offset(0.0, 150.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 4.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=4.0)
    child 13: RenderFlex#a1d5c relayoutBoundary=up1
        parentData: offset=Offset(0.0, 154.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 16.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: center
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderSemanticsAnnotations#8c237 relayoutBoundary=up2
            parentData: offset=Offset(0.0, 1.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(14.0, 14.0)
            child: RenderExcludeSemantics#28809 relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(14.0, 14.0)
                excluding: true
                child: RenderConstrainedBox#1c054 relayoutBoundary=up4
                    parentData: <none> (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(14.0, 14.0)
                    additionalConstraints: BoxConstraints(w=14.0, h=14.0)
        child 2: RenderConstrainedBox#d3085 relayoutBoundary=up2
            parentData: offset=Offset(14.0, 8.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(4.0, 0.0)
            additionalConstraints: BoxConstraints(w=4.0, 0.0<=h<=Infinity)
        child 3: RenderParagraph#81c93 relayoutBoundary=up2
            parentData: offset=Offset(18.0, 0.0); flex=1; fit=FlexFit.tight (can use size)
            constraints: BoxConstraints(w=276.0, 0.0<=h<=Infinity)
            size: Size(276.0, 16.0)
            textAlign: start
            textDirection: ltr
            softWrap: wrapping at box width
            overflow: ellipsis
            textScaler: SystemTextScaler (0.84997x)
            locale: en_US
            maxLines: unlimited
            text: TextSpan
                debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
                inherit: false
                color: Color(alpha: 1.0000, red: 0.4588, green: 0.4588, blue: 0.4588, colorSpace: ColorSpace.sRGB)
                family: Inter
                size: 12.0
                weight: 400
                letterSpacing: 0.0
                baseline: alphabetic
                height: 1.6x
                leadingDistribution: even
                decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
                "Individual Consultation"
    child 14: RenderConstrainedBox#0559b relayoutBoundary=up1
        parentData: offset=Offset(0.0, 170.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 6.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=6.0)
    child 15: RenderFlex#eea73 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 176.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 16.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: start
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderSemanticsAnnotations#d2501 relayoutBoundary=up2
            parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(14.0, 14.0)
            child: RenderExcludeSemantics#cc24c relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(14.0, 14.0)
                excluding: true
                child: RenderConstrainedBox#e38e9 relayoutBoundary=up4
                    parentData: <none> (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(14.0, 14.0)
                    additionalConstraints: BoxConstraints(w=14.0, h=14.0)
        child 2: RenderConstrainedBox#7769e relayoutBoundary=up2
            parentData: offset=Offset(14.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(4.0, 0.0)
            additionalConstraints: BoxConstraints(w=4.0, 0.0<=h<=Infinity)
        child 3: RenderParagraph#db629 relayoutBoundary=up2
            parentData: offset=Offset(18.0, 0.0); flex=1; fit=FlexFit.tight (can use size)
            constraints: BoxConstraints(w=276.0, 0.0<=h<=Infinity)
            size: Size(276.0, 16.0)
            textAlign: start
            textDirection: ltr
            softWrap: wrapping at box width
            overflow: ellipsis
            textScaler: SystemTextScaler (0.84997x)
            locale: en_US
            maxLines: 2
            text: TextSpan
                debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
                inherit: false
                color: Color(alpha: 1.0000, red: 0.3804, green: 0.3804, blue: 0.3804, colorSpace: ColorSpace.sRGB)
                family: Inter
                size: 12.0
                weight: 400
                letterSpacing: 0.0
                baseline: alphabetic
                height: 1.6x
                leadingDistribution: even
                decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
                "Counseling"
    child 16: RenderConstrainedBox#2b295 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 192.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(0.0, 6.0)
        additionalConstraints: BoxConstraints(0.0<=w<=Infinity, h=6.0)
    child 17: RenderFlex#1d1bf relayoutBoundary=up1
        parentData: offset=Offset(0.0, 198.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 16.0)
        direction: horizontal
        mainAxisAlignment: start
        mainAxisSize: max
        crossAxisAlignment: start
        textDirection: ltr
        verticalDirection: down
        spacing: 0.0
        child 1: RenderSemanticsAnnotations#38d0e relayoutBoundary=up2
            parentData: offset=Offset(0.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(14.0, 14.0)
            child: RenderExcludeSemantics#90df7 relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(unconstrained)
                size: Size(14.0, 14.0)
                excluding: true
                child: RenderConstrainedBox#e250c relayoutBoundary=up4
                    parentData: <none> (can use size)
                    constraints: BoxConstraints(unconstrained)
                    size: Size(14.0, 14.0)
                    additionalConstraints: BoxConstraints(w=14.0, h=14.0)
        child 2: RenderConstrainedBox#47f2b relayoutBoundary=up2
            parentData: offset=Offset(14.0, 0.0); flex=null; fit=null (can use size)
            constraints: BoxConstraints(unconstrained)
            size: Size(4.0, 0.0)
            additionalConstraints: BoxConstraints(w=4.0, 0.0<=h<=Infinity)
        child 3: RenderParagraph#5593b relayoutBoundary=up2
            parentData: offset=Offset(18.0, 0.0); flex=1; fit=FlexFit.tight (can use size)
            constraints: BoxConstraints(w=276.0, 0.0<=h<=Infinity)
            size: Size(276.0, 16.0)
            textAlign: start
            textDirection: ltr
            softWrap: wrapping at box width
            overflow: ellipsis
            textScaler: SystemTextScaler (0.84997x)
            locale: en_US
            maxLines: 3
            text: TextSpan
                debugLabel: ((englishLike bodyMedium 2021).merge((((blackMountainView bodyMedium).apply).apply).merge(unknown))).merge(unknown)
                inherit: false
                color: Color(alpha: 1.0000, red: 0.3804, green: 0.3804, blue: 0.3804, colorSpace: ColorSpace.sRGB)
                family: Inter
                size: 12.0
                weight: 400
                letterSpacing: 0.0
                baseline: alphabetic
                height: 1.6x
                leadingDistribution: even
                decoration: Color(alpha: 1.0000, red: 0.1020, green: 0.1020, blue: 0.1020, colorSpace: ColorSpace.sRGB) TextDecoration.none
                "ekdhsi wgruwef erjg ufy f"
    child 18: RenderConstrainedBox#3ad56 relayoutBoundary=up1
        parentData: offset=Offset(0.0, 214.0); flex=1; fit=FlexFit.tight (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, h=0.0)
        size: Size(0.0, 0.0)
        additionalConstraints: BoxConstraints(w=0.0, h=0.0)
    child 19: RenderConstrainedBox#c4a4c relayoutBoundary=up1
        parentData: offset=Offset(0.0, 214.0); flex=null; fit=null (can use size)
        constraints: BoxConstraints(0.0<=w<=294.0, 0.0<=h<=Infinity)
        size: Size(294.0, 48.0)
        additionalConstraints: BoxConstraints(w=Infinity, 0.0<=h<=Infinity)
        child: RenderSemanticsAnnotations#cabdb relayoutBoundary=up2
            parentData: <none> (can use size)
            constraints: BoxConstraints(w=294.0, 0.0<=h<=Infinity)
            semantic boundary
            size: Size(294.0, 48.0)
            child: _RenderInputPadding#f2bcf relayoutBoundary=up3
                parentData: <none> (can use size)
                constraints: BoxConstraints(w=294.0, 0.0<=h<=Infinity)
                size: Size(294.0, 48.0)
                child: RenderConstrainedBox#ddb75 relayoutBoundary=up4
                    parentData: offset=Offset(0.0, 4.0) (can use size)
                    constraints: BoxConstraints(w=294.0, 0.0<=h<=Infinity)
                    size: Size(294.0, 40.0)
                    additionalConstraints: BoxConstraints(64.0<=w<=Infinity, 40.0<=h<=Infinity)
◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤◢◤
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════

════════ Exception caught by rendering library ═════════════════════════════════
A RenderFlex overflowed by 11 pixels on the bottom.
The relevant error-causing widget was:
    Column Column:file:///C:/Users/Acer/StudioProjects/counselign/lib/counselorscreen/counselor_follow_up_sessions_screen.dart:395:16
════════════════════════════════════════════════════════════════════════════════