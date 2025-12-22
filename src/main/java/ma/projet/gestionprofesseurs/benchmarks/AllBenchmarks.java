package ma.projet.gestionprofesseurs.benchmarks;

import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

/**
 * Main class to run all JMH benchmarks.
 * This class runs all benchmark classes in the project.
 */
public class AllBenchmarks {
    
    public static void main(String[] args) throws RunnerException {
        Options opt = new OptionsBuilder()
                .include(".*Benchmark.*")  // Include all benchmark classes
                .forks(1)
                .warmupIterations(3)
                .measurementIterations(5)
                .build();
        
        new Runner(opt).run();
    }
}
