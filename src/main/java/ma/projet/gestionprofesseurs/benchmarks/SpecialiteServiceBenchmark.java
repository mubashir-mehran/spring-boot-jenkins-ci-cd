package ma.projet.gestionprofesseurs.benchmarks;

import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.SpecialiteRepository;
import ma.projet.gestionprofesseurs.services.SpecialiteService;
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.*;
import java.util.concurrent.TimeUnit;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

/**
 * JMH Microbenchmark for SpecialiteService methods.
 * Measures performance of CRUD operations.
 */
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(1)
@State(Scope.Benchmark)
public class SpecialiteServiceBenchmark {
    
    private SpecialiteService specialiteService;
    private SpecialiteRepository specialiteRepository;
    private Specialite testSpecialite;
    
    @Setup(Level.Trial)
    public void setup() {
        // Create mock repository
        specialiteRepository = mock(SpecialiteRepository.class);
        
        // Create service with mocked repository
        specialiteService = new SpecialiteService();
        // Use reflection to inject the mock
        try {
            java.lang.reflect.Field field = SpecialiteService.class.getDeclaredField("specialiteRepository");
            field.setAccessible(true);
            field.set(specialiteService, specialiteRepository);
        } catch (Exception e) {
            throw new RuntimeException("Failed to inject mock repository", e);
        }
        
        // Setup test data
        testSpecialite = new Specialite("CS", "Computer Science");
        testSpecialite.setId(1);
        
        // Setup mock behavior
        when(specialiteRepository.save(any(Specialite.class))).thenReturn(testSpecialite);
        when(specialiteRepository.findAll()).thenReturn(Arrays.asList(testSpecialite));
        when(specialiteRepository.findById(anyInt())).thenReturn(Optional.of(testSpecialite));
        doNothing().when(specialiteRepository).delete(any(Specialite.class));
    }
    
    /**
     * Benchmark for create operation
     */
    @Benchmark
    public Specialite benchmarkCreate() {
        Specialite newSpecialite = new Specialite("MATH", "Mathematics");
        return specialiteService.create(newSpecialite);
    }
    
    /**
     * Benchmark for findAll operation
     */
    @Benchmark
    public List<Specialite> benchmarkFindAll() {
        return specialiteService.findAll();
    }
    
    /**
     * Benchmark for findById operation
     */
    @Benchmark
    public Specialite benchmarkFindById() {
        return specialiteService.findById(1);
    }
    
    /**
     * Benchmark for update operation
     */
    @Benchmark
    public Specialite benchmarkUpdate() {
        Specialite updateSpec = new Specialite("PHY", "Physics");
        updateSpec.setId(1);
        return specialiteService.update(updateSpec);
    }
    
    /**
     * Benchmark for delete operation
     */
    @Benchmark
    public boolean benchmarkDelete() {
        return specialiteService.delete(testSpecialite);
    }
    
    /**
     * Main method to run benchmarks
     */
    public static void main(String[] args) throws RunnerException {
        Options opt = new OptionsBuilder()
                .include(SpecialiteServiceBenchmark.class.getSimpleName())
                .result("target/jmh-results/specialite-service-results.txt")
                .resultFormat(org.openjdk.jmh.results.format.ResultFormatType.TEXT)
                .build();
        
        new Runner(opt).run();
    }
}
