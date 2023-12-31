//ss
//the frames for the factory/crate icons

namespace FactoryFrame
{
	enum Frame
	{
		unknown = 0,

		longboat = 1,
		warboat,
		gunship,
		catapult = 4,
		ballista,
		mounted_bow,
		fighter = 7,
		saw = 8,
		drill,
		dinghy,
		bomber2 = 11,
		military_basics = 12,
		explosives,
		pyro,
		water_ammo,

		boulder = 16,
		expl_ammo,
		bison = 22,
		shark = 23,
		factory = 24,
		healing = 25,
		kitchen = 26,
		nursery = 27,
		tunnel = 28,
		storage = 29,

		//end of actual factory/crate icons
		count,

		//hack: these share above icons
		//but are used for scroll frame instead.
		magic_gib = 24,
		magic_midas,
		magic_drought,
		magic_flood,
	};
};
