module taperedRod(baseRadius = 3, height = 20, taperStartHeightPercentage = 60, taperPercentage = 75) {
    taperResolution = $fn < 8 ? 8 : $fn;
    baseHeight = height * taperStartHeightPercentage / 100;
    taperHeight = height - baseHeight;
    taperLength = sqrt(pow(taperHeight, 2) + pow(baseRadius, 2));
    echo ("baseHeight:", baseHeight, "taperHeight:", taperHeight, "taperLength:", taperLength);
    arcStartAngle = 0;
    arcEndAngle = 2 * acos(taperHeight / taperLength);
    arcRadius = taperHeight/sin(arcEndAngle);
    echo ("arcStartAngle:", arcStartAngle, "arcEndAngle:", arcEndAngle, "arcRadius:", arcRadius);
    arcCenterX = baseRadius - arcRadius;
    arcCenterY = baseHeight;
    taperAngleDelta = arcEndAngle / taperResolution;
    echo ("taperResolution", taperResolution, "arcCenterX:", arcCenterX, "arcCenterY:", arcCenterY);

    points = [ for (i = [0 : taperResolution]) [ arcCenterX + arcRadius * cos(i * taperAngleDelta), arcCenterY + arcRadius * sin(i * taperAngleDelta)] ];
    rotate_extrude($fn = 2 *taperResolution) polygon( concat([[0, 0], [baseRadius, 0]], points) );
}

module taperedHelix(baseRadius = 3, height = 20, taperStartHeightPercentage = 60, taperPercentage = 75, numberOfTurns = 7, threadDepth = 1.5, threadHeight = 2, threadTaperPercentage = 90) {
    helixResolution = $fn < 8 ? 8 : $fn;
    baseHeight = height * taperStartHeightPercentage / 100;
    taperHeight = height - baseHeight;
    taperLength = sqrt(pow(taperHeight, 2) + pow(baseRadius, 2));
    echo ("baseHeight:", baseHeight, "taperHeight:", taperHeight, "taperLength:", taperLength);
    arcStartAngle = 0;
    arcEndAngle = 2 * acos(taperHeight / taperLength);
    arcRadius = taperHeight/sin(arcEndAngle);
    echo ("arcStartAngle:", arcStartAngle, "arcEndAngle:", arcEndAngle, "arcRadius:", arcRadius);
    arcCenterX = baseRadius - arcRadius;
    arcCenterY = baseHeight;
    taperAngleDelta = arcEndAngle / helixResolution;
    taperFinalRadius = 0;
    echo ("helixResolution", helixResolution, "arcCenterX:", arcCenterX, "arcCenterY:", arcCenterY, "taperFinalRadius:", taperFinalRadius);
    circleAngleDelta = 180 / helixResolution;
    turnHeight = height / numberOfTurns;
    heightDelta = turnHeight / (2 * helixResolution);
    echo ("circleAngleDelta:", circleAngleDelta, "turnHeight:", turnHeight, "heightDelta:", heightDelta);

    horizontalPointDistance = 2 * sin(circleAngleDelta / 2) * baseRadius;
    slopeAngle = atan(heightDelta/horizontalPointDistance);

    threadEndHeight = threadHeight * (100 - threadTaperPercentage) / 100;
    threaEndHeightDelta = (threadHeight - threadEndHeight) / 2;

    for ( i = [1 : numberOfTurns * helixResolution * 2] ) {
        startRotation = (i - 1) * circleAngleDelta;
        startBottomHeight = (i - 1) * heightDelta;
        startTopHeight = startBottomHeight + threadHeight;
        endRotation = i * circleAngleDelta;
        endBottomHeight = i * heightDelta;
        endTopHeight = endBottomHeight + threadHeight;

        if (endTopHeight < height) {
            startBottomInnerRadius = startBottomHeight > baseHeight ? sqrt(pow(arcRadius, 2) - pow(startBottomHeight - arcCenterY, 2)) + arcCenterX : baseRadius;
            startRelativeDepth = startBottomHeight > baseHeight ? threadDepth * startBottomInnerRadius / baseRadius : threadDepth;
            startBottomOuterRadius = startBottomInnerRadius + startRelativeDepth;
            startBottomInnerX = startBottomInnerRadius * cos(startRotation);
            startBottomInnerY = startBottomInnerRadius * sin(startRotation);
            startBottomOuterX = startBottomOuterRadius * cos(startRotation);
            startBottomOuterY = startBottomOuterRadius * sin(startRotation);
            startTopInnerRadius = startTopHeight > baseHeight ? sqrt(pow(arcRadius, 2) - pow(startTopHeight - arcCenterY, 2)) + arcCenterX : baseRadius;
            startTopOuterRadius = startTopInnerRadius + startRelativeDepth;
            startTopInnerX = startTopInnerRadius * cos(startRotation);
            startTopInnerY = startTopInnerRadius * sin(startRotation);
            startTopOuterX = startBottomOuterX;
            startTopOuterY = startBottomOuterY;

            endBottomInnerRadius = endBottomHeight > baseHeight ? sqrt(pow(arcRadius, 2) - pow(endBottomHeight - arcCenterY, 2)) + arcCenterX : baseRadius;
            endRelativeDepth = endBottomHeight > baseHeight ? threadDepth * endBottomInnerRadius / baseRadius : threadDepth;
            endBottomOuterRadius = endBottomInnerRadius + endRelativeDepth;
            endBottomInnerX = endBottomInnerRadius * cos(endRotation);
            endBottomInnerY = endBottomInnerRadius * sin(endRotation);
            endBottomOuterX = endBottomOuterRadius * cos(endRotation);
            endBottomOuterY = endBottomOuterRadius * sin(endRotation);
            endTopInnerRadius = endTopHeight > baseHeight ? sqrt(pow(arcRadius, 2) - pow(endTopHeight - arcCenterY, 2)) + arcCenterX : baseRadius;
            endTopOuterRadius = endTopInnerRadius + endRelativeDepth;
            endTopInnerX = endTopInnerRadius * cos(endRotation);
            endTopInnerY = endTopInnerRadius * sin(endRotation);
            endTopOuterX = endBottomOuterX;
            endTopOuterY = endBottomOuterY;
            points = [
                [startBottomInnerX, startBottomInnerY, startBottomHeight],  // 0 - start bottom inner
                [startBottomOuterX, startBottomOuterY, startBottomHeight + threaEndHeightDelta],  // 1 - start bottom outer
                [startTopInnerX, startTopInnerY, startTopHeight],           // 2 - start top inner
                [startTopOuterX, startTopOuterY, startTopHeight - threaEndHeightDelta],           // 3 - start top outer
                [endBottomInnerX, endBottomInnerY, endBottomHeight],        // 4 - end bottom inner
                [endBottomOuterX, endBottomOuterY, endBottomHeight + threaEndHeightDelta],        // 5 - end bottom outer
                [endTopInnerX, endTopInnerY, endTopHeight],                 // 6 - end top inner
                [endTopOuterX, endTopOuterY, endTopHeight - threaEndHeightDelta]                  // 7 - end top outer
            ];
            triangles = [
                [0, 1, 5], [0, 5, 4], // bottom
                [2, 6, 7], [2, 7, 3], // top
                [0, 2, 3], [0, 3, 1], // inner
                [4, 5, 7], [4, 7, 6], // outer
                [0, 4, 6], [0, 6, 2], // start
                [1, 3, 7], [1, 7, 5]  // end
            ];

            polyhedron(points, triangles);
        }
    }
}

module taperedThreading(baseRadius = 3, height = 20, taperStartHeightPercentage = 60, taperPercentage = 75, numberOfTurns = 7, threadDepth = 1.5, threadHeight = 2, threadTaperPercentage = 90) {
    taperedRod(baseRadius, height, taperStartHeightPercentage, taperPercentage);
    taperedHelix(baseRadius, height, taperStartHeightPercentage, taperPercentage, numberOfTurns, threadDepth, threadHeight, threadTaperPercentage);
}
