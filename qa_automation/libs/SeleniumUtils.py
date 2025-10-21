import json

from robot.libraries.BuiltIn import BuiltIn
from polygon_generator import generate_polygon
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains


class SeleniumUtils:
    def __init__(self):
        self.driver = None    

    @staticmethod
    def use_current_webdriver(func):
        def wrapper(self, *args, **kwargs):
            if self.driver is None:
                selib = BuiltIn().get_library_instance("SeleniumLibrary")            
                self.driver = selib.driver
            return func(self, *args, **kwargs)
        return wrapper

    @use_current_webdriver
    def move_cursor_by_element_offset(self, webelement, x_offset: int, y_offset: int):
        """ The Cursor is moved to the center of the element and x/y coordinates are calculated from that point. """
        with ActionChains(self.driver) as action:
            action.move_to_element_with_offset(webelement, x_offset, y_offset).perform()

    @use_current_webdriver
    def cursor_click(self):
        with ActionChains(self.driver) as action:
            action.click().perform()

    @use_current_webdriver
    def cursor_double_click(self):
        with ActionChains(self.driver) as action:
            action.double_click().perform()

    @use_current_webdriver
    def cursor_right_click(self):
        with ActionChains(self.driver) as action:
            action.context_click().perform()

    @use_current_webdriver
    def set_browserstack_session_name(self):
        test_name = BuiltIn().get_variable_value('${TEST_NAME}')
        tags = BuiltIn().get_variable_value('${TEST_TAGS}')
        test_id = ''
        for case_tag in tags:
            if case_tag.startswith('TC'):
                test_id = case_tag
                break
        executor_object = {
            'action': 'setSessionName',
            'arguments': {
                'name': f'{test_id} - {test_name}'
            }
        }
        browserstack_executor = 'browserstack_executor: {}'.format(json.dumps(executor_object))
        self.driver.execute_script(browserstack_executor)

    @use_current_webdriver
    def get_webelement_css_property(self, element_locator: str, property_name: str):
        css_value = None
        locator = element_locator.split('=')
        if locator[0].strip().lower() == 'xpath':
            css_value = self.driver.find_element(By.XPATH, locator[1].strip()).value_of_css_property(property_name)
        elif locator[0].strip().lower() == 'sh-id':
            css_value = self.driver.find_element(By.XPATH, f"//*[@sh-id='{locator[1].strip()}']").value_of_css_property(property_name)
        return css_value

    @staticmethod
    def generate_ui_coordinates(points_number: int,
                                center_x: int, center_y: int,
                                avg_radius: int) -> list:

        coords_list = generate_polygon(center=(center_x, center_y),
                                       avg_radius=avg_radius,
                                       irregularity=0.3,
                                       spikiness=0.4,
                                       min_dist=10,
                                       num_vertices=points_number)
        coords_list = [[int(coord[0]), int(coord[1])] for coord in coords_list]
        return coords_list
    
    @use_current_webdriver
    def get_current_browser_name(self):
        name = self.driver.caps['browserName']
        return  name
