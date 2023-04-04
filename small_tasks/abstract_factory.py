from abc import ABC, abstractmethod


class Body(ABC):
    @abstractmethod
    def assembly_engine(self):
        """engine type"""

    @abstractmethod
    def set_body_type(self):
        """body type"""


class Hardware(ABC):
    @abstractmethod
    def put_console(self):
        """console type"""

    @abstractmethod
    def assembly_seats(self):
        """seat type"""


class RegularBody(Body):
    def assembly_engine(self):
        print('1.2 Motor')

    def set_body_type(self):
        print('Hatchback')


class SportBody(Body):
    def assembly_engine(self):
        print('2.0 Motor')

    def set_body_type(self):
        print('Sedan')


class StandartHardware(Hardware):
    def put_console(self):
        print('Small screen')

    def assembly_seats(self):
        print('Normal')


class LuxuryHardware(Hardware):
    def put_console(self):
        print('Big screen')

    def assembly_seats(self):
        print('Leathuer')


class CarFactory(ABC):
    @abstractmethod
    def get_body(self):
        """Body type"""

    @abstractmethod
    def get_hardware(self):
        """Hardware type"""


class FamilyCar(CarFactory):
    def get_body(self):
        return RegularBody()

    def get_hardware(self):
        return StandartHardware()


class OutdoorCar(CarFactory):
    def get_body(self):
        return SportBody()

    def get_hardware(self):
        return StandartHardware()


class BachelorCar(CarFactory):
    def get_body(self):
        return RegularBody()

    def get_hardware(self):
        return LuxuryHardware()


class WealthyCar(CarFactory):
    def get_body(self):
        return SportBody()

    def get_hardware(self):
        return LuxuryHardware()


def prepare_order(customer):
    factories = {
        "Family": FamilyCar(),
        "Outdoor": OutdoorCar(),
        "Bachelor": BachelorCar(),
        "Wealthy": WealthyCar()
    }
    car = factories[customer]

    body_car = car.get_body()
    hardware_car = car.get_hardware()

    body_car.assembly_engine()
    body_car.assembly_engine()
    hardware_car.put_console()
    hardware_car.assembly_seats()


prepare_order('Family')
