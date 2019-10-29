
/**
 * linear interpolation between two PVectors
 * @param PVector first vector
 * @param PVector second vector
 * @param float unit interval
 * @return PVector interpolated
 */
PVector vecLerp(PVector a, PVector b, float l){
  return new PVector(lerp(a.x, b.x, l), lerp(a.y, b.y, l), 0);
}

//http://danceswithcode.net/engineeringnotes/rotations_in_3d/rotations_in_3d_part2.html
FloatList makeMatrix(float yaw, float pitch, float roll) {
        //Precompute sines and cosines of Euler angles
        float su = (float)Math.sin(roll);
        float cu = (float)Math.cos(roll);
        float sv = (float)Math.sin(pitch);
        float cv = (float)Math.cos(pitch);
        float sw = (float)Math.sin(yaw);
        float cw = (float)Math.cos(yaw);

        //Create and populate RotationMatrix
        FloatList m = new FloatList();
        m.append(cv*cw);
        m.append(su*sv*cw - cu*sw);
        m.append(su*sw + cu*sv*cw);
        m.append(cv*sw);
        m.append(cu*cw + su*sv*sw);
        m.append(cu*sv*sw - su*cw);
        m.append(-sv);
        m.append(su*cv);
        m.append(cu*cv);
        return m;
}

PVector matrixIt(PVector _p, FloatList _m) {
    float a = _m.get(0);
    float b = _m.get(1);
    float c = _m.get(2);

    float d = _m.get(3);
    float e = _m.get(4);
    float f = _m.get(5);

    float g = _m.get(6);
    float h = _m.get(7);
    float i = _m.get(8);

    float x = _p.x;
    float y = _p.y;
    float z = 1;

    float newX = a*x + b*y + c*z;
    float newY = d*x + e*y + f*z;
    float newZ = g*x + h*y + i*z;
    return new PVector(newX, newY, 0);//newZ);
}

PVector matrixIt(PVector _p) {
    float a = 1.54611;
    float b = 0.03157;
    float c = -104.0;

    float d = 0.14214;
    float e = 1.50488;
    float f = -114;

    float g = 0.00052;
    float h = 0.00014;
    float i = 1.0;


    float x = _p.x;
    float y = _p.y;
    float z = 1;

    float newX = a*x + b*y + c*z;
    float newY = d*x + e*y + f*z;
    float newZ = g*x + h*y + i*z;
    return new PVector(newX, newY, 0);//newZ);
}
