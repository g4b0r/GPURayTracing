//
// Function prototypes
//
float intersectSphere(vec3 camera, vec3 ray, vec3 sphereOrigin, float sphereRadius);

//
// Intersect sphere and return the distance to the intersection point.
// A negative value is returned when the ray doesn't intersect the sphere.
//
float intersectSphere(vec3 camera, vec3 ray, vec3 sphereOrigin, float sphereRadius) {
    float radiusSquared = sphereRadius * sphereRadius;
    float dt = dot(ray, sphereOrigin - camera);
    if (dt < 0.0) {
        // The sphere is behind the camera
        return -1;
    }
    vec3 tmp = camera - sphereOrigin;
    tmp.x = dot(tmp, tmp);
    tmp.x = tmp.x - dt * dt;
    if (tmp.x >= radiusSquared) {
        // The ray missed the sphere
        return -1;
    }
    float distanceFromCamera = dt - sqrt(radiusSquared - tmp.x);
    return distanceFromCamera;
}

void main() {
    vec3 lightPosition = vec3(0.0, 0.0, -1.0);
    vec3 spherePosition = vec3(0.0, 0.0, 2.0);
    float sphereRadius = 0.9;
    vec3 cameraPosition = vec3(0.0, 0.0, 0.0);
    
    vec2 uv = v_tex_coord * 2.0 - 1.0;  // Incoming pixel to shade
    uv.y = -uv.y;
    vec3 ray = vec3(uv.x, uv.y, 1.0);   // Generate a ray
    ray = normalize(ray);
    
    float distance = intersectSphere(cameraPosition, ray, spherePosition, sphereRadius);
    
    if (distance > 0.0) {
        
        vec3 pointOfIntersection = cameraPosition + ray * distance;
        vec3 normal = normalize(pointOfIntersection - spherePosition); // Surface normal
        
        float u = atan(normal.z, normal.x) / 3.1415926 * 2.0 + xOffset;
        float v = asin(normal.y) / 3.1415926 * 2.0 + yOffset;
        
        float brightness = dot(normalize(lightPosition - spherePosition), normal);
        brightness = brightness * brightness;
        
        u = mod(u * 8.0, 8.0);
        v = mod(v * 8.0, 8.0);
        
        vec4 color = texture2D(u_texture, vec2(fract(u), 1.0-fract(v))) * brightness;
        gl_FragColor = vec4(color.r, color.g, color.b, 1.0);
    }
    else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
}
