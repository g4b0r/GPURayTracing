//
// Function prototypes
//
float intersectSphere(vec3 camera, vec3 ray, vec3 sphereOrigin, float sphereRadius);
mat3 xrot(float angle);
mat3 yrot(float angle);
mat3 zrot(float angle);

mat3 xrot(float angle) {
    mat3 m;
    m[0] = vec3(1.0, 0.0, 0.0);
    m[1] = vec3(0.0, cos(angle), -sin(angle));
    m[2] = vec3(0.0, sin(angle), cos(angle));
    return m;
}

mat3 yrot(float angle) {
    mat3 m;
    m[0] = vec3(cos(angle), 0.0, -sin(angle));
    m[1] = vec3(0.0, 1.0, 0.0);
    m[2] = vec3(sin(angle), 0.0, cos(angle));
    return m;
}

mat3 zrot(float angle) {
    mat3 m;
    m[0] = vec3(cos(angle), -sin(angle), 0.0);
    m[1] = vec3(sin(angle), cos(angle), 0.0);
    m[2] = vec3(0.0, 0.0, 1.0);
    return m;
}

//
// Intersect sphere and return the distance to the intersection point.
// A negative value is returned when the ray doesn't intersect the sphere.
//
float intersectSphere(vec3 camera, vec3 ray, vec3 sphereOrigin, float sphereRadius) {
    float radiusSquared = sphereRadius * sphereRadius;
    float dt = dot(ray, sphereOrigin - camera);
    if (dt < 0.0) {
        // The sphere is behind the camera
        return -1.0;
    }
    vec3 tmp = camera - sphereOrigin;
    tmp.x = dot(tmp, tmp);
    tmp.x = tmp.x - dt * dt;
    if (tmp.x >= radiusSquared) {
        // The ray missed the sphere
        return -1.0;
    }
    float distanceFromCamera = dt - sqrt(radiusSquared - tmp.x);
    return distanceFromCamera;
}

void main() {
    vec3 lightPosition = vec3(0.0, 0.0, -25.0);
    vec3 spherePosition = vec3(0.0, 0.0, 0.0);
    float sphereRadius = 1.4;
    vec3 cameraPosition = vec3(0.0, 0.0, -10.0);
    
    vec2 uv = v_tex_coord * 2.0 - 1.0;  // Incoming pixel to shade
    vec3 pixelPosition = vec3(uv.x / 3.5, uv.y / 3.5, -9.0);
    
    vec3 ray = pixelPosition - cameraPosition;  // Generate a ray
    ray = normalize(ray);
    
    ray = ray * xrot(yOffset) * yrot(xOffset);
    cameraPosition = cameraPosition * xrot(yOffset) * yrot(xOffset);
    
    lightPosition = lightPosition * yrot(-u_time / 5.0);
    
    float distance = intersectSphere(cameraPosition, ray, spherePosition, sphereRadius);
    
    if (distance > 0.0) {
        
        vec3 pointOfIntersection = cameraPosition + ray * distance;
        vec3 normal = normalize(pointOfIntersection - spherePosition); // Surface normal
        
        float u = 0.5 + atan(normal.z, normal.x) / (3.1415926 * 2.0);
        float v = 0.5 - asin(normal.y) / -3.1415926;
        
        float brightness = dot(normalize(lightPosition - spherePosition), normal);
        if (brightness < 0.0) {
            brightness = 0.0;
        }
        
        vec4 earthColor = texture2D(u_texture, vec2(fract(u), fract(v)));
        vec4 earthLights = texture2D(texture_lights, vec2(fract(u), fract(v)));
        vec4 cloudColor = texture2D(texture_clouds, vec2(fract(u + (u_time / 1000.0)), fract(v))) * brightness;
        vec4 cloudAlpha = texture2D(texture_clouds_alpha, vec2(fract(u + (u_time / 1000.0)), fract(v)));
        
        earthColor = earthColor * brightness + earthLights * ((1.0 - brightness) * 0.4);
        
        vec4 color = earthColor * cloudAlpha.r + cloudColor * (1.0 - cloudAlpha.r);
        
        gl_FragColor = vec4(color.r, color.g, color.b, 1.0);
    }
    else {
        mat2 rot;
        float deg = u_time / 100.0;
        rot[0] = vec2(cos(deg), sin(deg));
        rot[1] = vec2(-sin(deg), cos(deg));
        
        vec2 uv = v_tex_coord.xy;
        uv = uv - vec2(.5);
        uv = uv * rot;
        uv = uv + vec2(.5);
        
        vec4 color = texture2D(texture_stars, vec2(fract(uv.x), fract(uv.y))) * 0.4;
        gl_FragColor = vec4(color.r, color.g, color.b, 1.0);
    }
}
