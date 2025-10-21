import os
import sys
import cv2
import json
import math
import uuid
import random
import string
import secrets
import geopy.distance

from shapely import Polygon
from jsonschema import validate, RefResolver
from polygon_generator import generate_polygon
from datetime import datetime, timezone
from pytz import timezone as ZoneInfo


def generate_SECRET_PROJECT_edges(location: dict, SECRET_PROJECT_type: str = None) -> list:
    if SECRET_PROJECT_type=='MOVEMENT':
        return [0]
    if len(location['coordinates']) == 0:
        return []
    edges = []
    i = 0
    for coord in location['coordinates']:
        for point in coord:
            edges.append(i)
            i += 1
    return edges[:-1]

def create_herd_slots(paddock_ids: list = [], date: int = None) -> list:
    slots = []
    for i in range(16):
        slots.append(dict(nextWhen=None,
                          currentActive=False,
                          nextActive=False,
                          currentActions=[],
                          nextActions=[],
                          state='COMPLETE',
                          index=i))
    for i, paddock in enumerate(paddock_ids):
        slots[i]['nextPaddockId'] = paddock
        slots[i]['nextActive'] = True
        slots[i]['nextWhen'] = date
        slots[i]['nextActions'] = [{'timeOffset': 0,
                                    'type': 'ENABLE_SECRET_PROJECT'},
                                    {'timeOffset': 8640,
                                    'type': 'DISABLE_SECRET_PROJECT'}]
    return slots

def check_if_list_of_dicts_is_sorted(list_of_dicts: list, field_name: str, order: str) -> bool:
    if type(list_of_dicts[0][field_name]) == str:
        for i in range(len(list_of_dicts)):
            list_of_dicts[i][field_name] = list_of_dicts[i][field_name].lower()

    actual_list = [list_of_dicts[i][field_name] for i in range(len(list_of_dicts))]
    print(f'Actual order: {actual_list}')
    if order.lower() == 'asc':
        sorted_list = sorted(actual_list)
    elif order.lower() == 'desc':
        sorted_list = sorted(actual_list,  reverse=True)
    else:
        raise ValueError('Order must be either "asc" or "desc"')
    
    print(f'Expected order: {sorted_list}')
    return actual_list == sorted_list

def validate_json_schema_by_file(schema_name: str, json_data: dict):
    schema_dir = os.path.join(os.path.dirname(__file__), os.path.normpath('../resources/api/Schemas'))
    schema_path = os.path.join(schema_dir, schema_name)
    with open(schema_path, "r") as f:
        schema = json.load(f)
    schema_base_dir = 'file:///{}/'.format(schema_dir.replace("\\", "/"))
    resolver = RefResolver(schema_base_dir, schema)
    validate(json_data, schema=schema, resolver=resolver)

def generate_hex_color() -> str:
    color = secrets.token_hex(3)
    return '#'+color

def normalize_coords(x_coord: float, y_coord: float) -> list:
        # Normalize x coord to [-180; 180]
        if x_coord > 180:
            x_norm = -180 + (x_coord - 180)
        elif x_coord < -180:
            x_norm = 180 - (-180 - x_coord)
        else:
            x_norm = x_coord
        # Normalize y coord to [-90; 90]
        if y_coord > 90:
            y_norm = 90 - (y_coord - 90)
        elif y_coord < -90:
            y_norm = -90 + (-90 - y_coord)
        else:
            y_norm = y_coord        
        return [x_norm, y_norm]

def generate_map_coordinates(points_number: int) -> list:    
    x_init = random.uniform(-180, 180)
    y_init = random.uniform(-90, 90)
    coords_list = generate_polygon(center=(x_init, y_init),
                                    avg_radius=0.006,
                                    irregularity=0.3,
                                    spikiness=0.4,
                                    min_dist=0.0001,
                                    num_vertices=points_number)
    coords_list = [normalize_coords(*coord) for coord in coords_list]
    return coords_list

def generate_polygon_map_coordinates(points_number: int) -> list:
    while True:
        coords = generate_map_coordinates(points_number)
        coords.append(coords[0])
        reverted_list = [coords[::-1]]
        pp = Polygon(reverted_list[0])
        if pp.is_valid:
            return  reverted_list

def generate_rectangle_map_coordinates() -> list:
    center_lon = random.uniform(-180, 180)
    center_lat = random.uniform(-90, 90)
    height_km = random.uniform(0.5, 2)
    width_km = height_km * random.uniform(1, 2.5)

    d_lat = geopy.distance.distance(kilometers=height_km / 2).destination((center_lat, center_lon), 0)[0] - center_lat
    d_lon = geopy.distance.distance(kilometers=width_km / 2).destination((center_lat, center_lon), 90)[1] - center_lon

    nw = [center_lat + d_lat, center_lon - d_lon]
    ne = [center_lat + d_lat, center_lon + d_lon]
    se = [center_lat - d_lat, center_lon + d_lon]
    sw = [center_lat - d_lat, center_lon - d_lon]
    coords_list = [normalize_coords(*coord) for coord in [nw, ne, se, sw]]
    return coords_list

def crop_image(x1: int, y1: int, x2: int, y2: int, image_path: str):
    image = cv2.imread(image_path)
    cropped_image = image[y1:y2, x1:x2]
    cv2.imwrite(image_path, cropped_image)

def compare_images_histograms(img_a_path: str, img_b_path:str) -> float:
    # Load the images
    img_a = cv2.imread(img_a_path)
    img_b = cv2.imread(img_b_path)

    # Calculate the histograms, and normalize them
    hist_img1 = cv2.calcHist([img_a], [0, 1, 2], None, [256, 256, 256], [0, 256, 0, 256, 0, 256])
    cv2.normalize(hist_img1, hist_img1, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX)
    hist_img2 = cv2.calcHist([img_b], [0, 1, 2], None, [256, 256, 256], [0, 256, 0, 256, 0, 256])
    cv2.normalize(hist_img2, hist_img2, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX)

    # Find the metric value
    metric_val = cv2.compareHist(hist_img1, hist_img2, cv2.HISTCMP_BHATTACHARYYA)
    return metric_val

def generate_UUID():
    return  str(uuid.uuid4())

def generate_string_with_random_length(min_len: int, max_len: int, chars=string.ascii_uppercase + string.digits):
    size = random.randint(min_len, max_len)
    return ''.join(random.choice(chars) for _ in range(size))

def get_random_int64():
    return  random.randint(0, sys.maxsize)

def shuffle_list_items(l: list):
    random.shuffle(l)
    return  l

def generate_random_dates_within_24_hours(start_datetime: int = 15778368000000, end_datetime: int = 22721471990000) -> tuple:
    random_start_time = random.randint(start_datetime, end_datetime - 864000000)
    random_end_time = random_start_time + 864000000
    return random_start_time, random_end_time


def adjust_unix_time(unix_time: int = 1728303594653, timezone_str: str = 'Asia/Tbilisi') -> int:
    # Convert Unix time (milliseconds) to a datetime object in UTC
    dt_utc = datetime.fromtimestamp(unix_time / 1000, tz=timezone.utc)
    # Create timezone object
    tz = ZoneInfo(timezone_str)
    # Convert UTC datetime to the target timezone
    dt_tz = dt_utc.astimezone(tz)
    # Calculate the timezone offset in seconds
    offset_seconds = dt_tz.utcoffset().total_seconds()
    # Adjust the Unix time by the timezone offset (in milliseconds)
    adjusted_unix_time = unix_time + (offset_seconds * 1000)
    return int(adjusted_unix_time)
