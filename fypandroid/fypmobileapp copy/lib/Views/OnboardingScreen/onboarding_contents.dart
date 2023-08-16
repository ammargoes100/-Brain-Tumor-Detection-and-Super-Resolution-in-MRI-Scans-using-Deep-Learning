class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Tumor Tool",
    image: "Assets/doctor_transpnobg.png",
    desc: "Designed For Patients and Medical Experts to diagnose MRI Scans.",
  ),
  OnboardingContents(
    title: "Magnetic Resonance Images",
    image: "Assets/MRIBRAIN.png",
    desc: "MRI is the most effective image technique to help doctors identify the size, location and type of brain tumor",
  ),
  OnboardingContents(
    title: "Powered With Artificial intelligence",
    image: "Assets/ainobg.png",
    desc: "With the use of image processing models, Brian tumor detection is made easy",
  ),
];
